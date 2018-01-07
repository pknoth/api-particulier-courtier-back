# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def create?
    user ? true : false
  end

  def update?
    false
  end

  class Scope < Scope
    def resolve
      return scope.all if user.dgfip?
      return scope.where(subscription_id: Subscription.with_role(:applicant, user).pluck(:id)) if user.france_connect?
    end
  end
end
