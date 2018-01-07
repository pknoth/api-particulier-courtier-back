class AddNameToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :name, :string
  end
end
