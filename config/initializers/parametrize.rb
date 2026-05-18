module ParameterizeWithAutoLocale
  def smart_parameterize(separator: '-', preserve_case: false)
    locale = detect_locale(self)
    parameterize(locale: locale, separator: separator, preserve_case: preserve_case)
  end

  private

  def detect_locale(str)
    if str.match?(/\p{Cyrillic}/)
      :ru
    else
      :en
    end
  end
end

String.include(ParameterizeWithAutoLocale)
