class AddHumanNameToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :human_name, :string
  end
end
