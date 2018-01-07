class AddHumanNameToFields < ActiveRecord::Migration[5.1]
  def change
    add_column :fields, :human_name, :string
  end
end
