class ScopeSubscription < ApplicationRecord
  belongs_to :scope
  belongs_to :subscription

  before_save :overwrite

  def overwrite
    subscription
      .scope_subscriptions
      .where(scope: scope)
      .delete_all
  end
end
