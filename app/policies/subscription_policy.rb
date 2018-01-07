# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def create?
    return false unless user.france_connect?
    true
  end

  def update?
    res = false
    res = true if record.can_fill_application? || record.can_complete_application?
    res && user.france_connect?
  end

  def convention?
    record.can_sign_convention? || record.can_deploy? || record.deployed?
  end

  def fill_application?
    user.france_connect? && record.can_fill_application?
  end

  def complete_application?
    user.france_connect? && record.can_complete_application?
  end

  def approve_application?
    user.dgfip? && record.can_approve_application?
  end

  def refuse_application?
    user.dgfip? && record.can_refuse_application?
  end

  def sign_convention?
    user.france_connect? && record.can_sign_convention?
  end

  def deploy?
    user.france_connect? && record.can_deploy?
  end

  class Scope < Scope
    def resolve
      if user.dgfip?
        scope.all
      else
        scope.with_role(:applicant, user)
      end
    end
  end
end
