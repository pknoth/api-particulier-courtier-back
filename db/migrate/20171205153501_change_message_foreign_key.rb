class ChangeMessageForeignKey < ActiveRecord::Migration[5.1]
  def change
    remove_column :messages, :enrollment_id, :integer
    add_column :messages, :subscription_id, :integer
  end
end
