class CreateScopeSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :scope_subscriptions do |t|
      t.integer :subscription_id
      t.integer :scope_id
      t.boolean :selected

      t.timestamps
    end
  end
end
