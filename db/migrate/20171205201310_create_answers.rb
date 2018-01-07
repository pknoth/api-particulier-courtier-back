class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.integer :subscription_id
      t.integer :field_id
      t.string :content

      t.timestamps
    end
  end
end
