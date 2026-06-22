# frozen_string_literal: true

# Сервис VariantGenerator
#
# Назначение:
#   Генерирует все возможные комбинации вариантов товара на основе выбранных
#   типов опций (OptionType) и их значений (OptionValue).
#   Создаёт записи Variant и связывающие VariantOptionValue.
#   Генерирует человеко-читаемый SKU.
#   Защищает от создания дубликатов (комбинация опций уже существует у товара).
#
# Пример использования:
#   result = VariantGenerator.call(
#     product,
#     {
#       color_type => [red_value, blue_value],
#       size_type  => [s_value, m_value]
#     },
#     default_price: 1999.0,
#     default_stock: 10
#   )
#
#   if result.success?
#     puts "Создано: #{result.created.size}"
#     puts "Пропущено (дубли): #{result.skipped.size}"
#   else
#     puts result.errors
#   end
#
# Входящий формат selected_options:
#   Hash, где ключ — OptionType (объект или UUID/integer id),
#         значение — массив OptionValue (объекты или их id).
#   Сервис сам нормализует id → объекты и проверяет принадлежность.
#
# Защита от дублей:
#   Используется продвинутый SQL-запрос с GROUP BY + HAVING + CASE.
#   Это гарантирует, что у найденного варианта ровно те же значения опций,
#   ни больше, ни меньше. Простой `WHERE option_value_id IN (...)` недостаточен.

module Products
  class VariantGenerator
    # faster than hash, result.succes? instead of result[:success] == more obj.oriental
    Result = Struct.new(:success?, :created, :skipped, :errors, :message, keyword_init: true)

    attr_reader :product, :selected_options, :default_price, :default_stock,
                :created_variants, :skipped_combinations, :errors

    # new class instance and insta .call
    def self.call(product, selected_options, default_price: nil, default_stock: 0)
      new(product, selected_options, default_price: default_price, default_stock: default_stock).call
    end

    def initialize(product, selected_options, default_price: nil, default_stock: 0)
      @product = product
      @raw_selected_options = selected_options
      @default_price = default_price || product.try(:price) || 0
      @default_stock = default_stock
      @created_variants = []
      @skipped_combinations = []
      @errors = []
    end

    def call
      return failure('Товар (product) обязателен') unless @product&.persisted? # AD method - true if obj in DB already
      return failure('Не выбрано ни одной опции для генерации') if @raw_selected_options.blank?

      begin
        # data normalize (same view)
        @selected_options = normalize_selected_options(@raw_selected_options)
        # is options really allowed to target product?
        validate_option_types_belong_to_product!
      rescue ActiveRecord::RecordNotFound, ArgumentError => e
        return failure(e.message)
      end
      generate_combinations.each do |combination| # combination — массив OptionValue (один из каждой группы)
        combo_names = combination.map { |ov| "#{ov.option_type.name}: #{ov.name}" }.join(' + ')

        if variant_exists_for_combination?(combination)
          @skipped_combinations << combo_names
          next
        end

        variant = build_variant(combination)

        if variant.save
          begin
            create_variant_option_values!(variant, combination)
            @created_variants << variant
          rescue ActiveRecord::RecordInvalid => e
            @errors << { combination: combo_names, error: e.message }
            # Вариант создан, но связи — нет. Удаляем orphan
            variant.destroy
          end
        else
          @errors << { combination: combo_names, error: variant.errors.full_messages.join(', ') }
        end
      end

      success
    end

    private

    # Нормализация входных данных:
    #   Позволяет передавать как объекты, так и их идентификаторы (UUID или integer).
    #   Это удобно при вызове из формы (params приходят как строки/uuid).
    def normalize_selected_options(raw)
      normalized = {}

      raw.each do |key, value_list|
        # Определяем OptionType
        option_type = if key.is_a?(OptionType)
                        key
                      else
                        OptionType.find(key)
                      end

        # Собираем OptionValue
        option_values = Array(value_list).map do |val|
          if val.is_a?(OptionValue)
            val
          else
            OptionValue.find(val)
          end
        end.uniq

        # Дополнительная проверка: все значения должны принадлежать этому типу опции
        option_values.each do |ov|
          if ov.option_type_id != option_type.id
            raise ArgumentError, "OptionValue '#{ov.name}' не принадлежит OptionType '#{option_type.name}'"
          end
        end

        normalized[option_type] = option_values
      end

      normalized
    end

    # Проверка, что все переданные типы опций действительно назначены товару
    # (через ProductOptionType). Защита от ошибок в UI/форме.
    def validate_option_types_belong_to_product!
      product_option_type_ids = @product.option_type_ids.to_set
      @selected_options.keys.each do |ot|
        unless product_option_type_ids.include?(ot.id)
          raise ArgumentError, "Тип опции '#{ot.name}' не доступен для данного товара"
        end
      end
    end

    # Генерация всех комбинаций (декартово произведение)
    #
    # Пример:
    #   Цвет: [Красный, Синий]
    #   Размер: [S, M]
    #
    #   Результат:
    #     [ [Красный, S], [Красный, M], [Синий, S], [Синий, M] ]
    #
    # Ruby Array#product — идеальный инструмент для этого.
    # Он эффективен и читаем. Для 4 опций по 3 значения = 81 комбинация — мгновенно.
    def generate_combinations
      value_arrays = @selected_options.values
      return [] if value_arrays.empty?

      # Если одна группа — product(*) вернёт [[val1], [val2], ...]
      # Если несколько — product(second, third, ...) сделает полное произведение.
      value_arrays.first.product(*value_arrays[1..])
    end

    # Самая важная часть — точная проверка существования варианта с такой же комбинацией.
    #
    # Почему нельзя просто:
    #   Variant.joins(:variant_option_values).where(option_value_id: ids).exists?
    # Потому что это найдёт вариант, у которого ЕСТЬ эти значения, но могут быть и ДРУГИЕ.
    # Нам нужна точная комбинация (ровно эти и только эти).
    #
    # Решение:
    #   Считаем общее количество связей у варианта (COUNT(*)) И
    #   количество связей, которые попали в наш список выбранных (COUNT CASE IN).
    #   Если оба равны размеру выбранного списка — значит у варианта ровно эти опции.
    #
    # Это классический паттерн "exact match на many-to-many" в SQL.
    # Работает на PostgreSQL (и MySQL/MariaDB тоже).
    def variant_exists_for_combination?(option_values)
      selected_ids = option_values.map(&:id)
      return false if selected_ids.empty?

      Variant.joins(:variant_option_values)
             .where(product_id: @product.id)
             .group('variants.id')
             .having(
               'COUNT(variant_option_values.id) = :size AND ' \
               'COUNT(CASE WHEN variant_option_values.option_value_id IN (:ids) THEN 1 END) = :size',
               size: selected_ids.size,
               ids: selected_ids
             )
             .exists?
    end

    # Создаём (но не сохраняем) объект Variant.
    # Здесь можно расширять: передавать дополнительные атрибуты,
    # вычислять цену по формуле и т.д.
    def build_variant(option_values)
      sku = generate_sku(option_values)

      Variant.new(
        product: @product,
        sku: sku,
        price: @default_price,
        stock: @default_stock
        # available_on: Time.current, etc.
      )
    end

    # Генерация SKU.
    # Текущая стратегия: BASE-ТИП1-ЗНАЧЕНИЕ1-ТИП2-ЗНАЧЕНИЕ2...
    #
    # Пример: TSHIRT-COLOR-RED-SIZE-M
    #
    # В реальном проекте рекомендуется:
    #   - Добавить в OptionValue поле `sku_code` (короткий код для SKU)
    #   - Или `internal_name`
    #   - Использовать I18n для красивых имён, а для SKU — технические коды
    #   - Добавить валидацию/уникальность SKU на уровне БД (unique index на product_id + sku)
    #
    # Здесь — стартовая реализация, легко улучшить.
    def generate_sku(option_values)
      base = if @product.respond_to?(:sku) && @product.sku.present?
               @product.sku.to_s.upcase
             else
               @product.slug.to_s.upcase.first(12)
             end

      option_parts = option_values.sort_by { |ov| [ov.option_type_id.to_s, ov.id.to_s] }.map do |ov|
        type_code  = ov.option_type.name.to_s.parameterize.upcase.first(5)
        value_code = ov.name.to_s.parameterize.upcase.first(10)
        "#{type_code}-#{value_code}"
      end

      "#{base}-#{option_parts.join('-')}"
    end

    def create_variant_option_values!(variant, option_values)
      option_values.each do |ov|
        VariantOptionValue.create!(
          variant: variant,
          option_value: ov
        )
      end
    end

    def success
      Result.new(
        success?: true,
        created: @created_variants,
        skipped: @skipped_combinations,
        errors: @errors,
        message: "Готово. Создано вариантов: #{@created_variants.size}. " \
                 "Пропущено дублей: #{@skipped_combinations.size}. " \
                 "Ошибок: #{@errors.size}."
      )
    end

    def failure(message)
      Result.new(
        success?: false,
        created: [],
        skipped: [],
        errors: [message],
        message: message
      )
    end
  end
end
