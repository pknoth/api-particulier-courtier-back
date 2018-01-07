class AddDescriptionToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :description, :text
  end
end
