class ChangeDocumentForeignKey < ActiveRecord::Migration[5.1]
  def change
    remove_column :documents, :enrollment_id, :integer
    add_column :documents, :subscription_id, :integer
  end
end
