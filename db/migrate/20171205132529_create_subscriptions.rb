class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.string :enrollment_id
      t.string :state

      t.timestamps
    end
  end
end
