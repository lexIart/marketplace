class ProductPolicy < ApplicationPolicy
  def index?
    user.seller?
  end

  def show?
    user.seller? && record.seller == user
  end

  def new?
    user.seller?
  end

  def create?
    user.seller?
  end

  def edit?
    user.seller? && record.seller == user
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.by_seller(user)
    end
  end
end
