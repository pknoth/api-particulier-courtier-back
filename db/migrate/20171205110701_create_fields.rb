class CreateFields < ActiveRecord::Migration[5.1]
  def change
    create_table :fields do |t|
      t.string :type
      t.integer :fieldable_id
      t.string :name
      t.string :fieldable_type
      t.text :description

      t.timestamps
    end
  end
end
