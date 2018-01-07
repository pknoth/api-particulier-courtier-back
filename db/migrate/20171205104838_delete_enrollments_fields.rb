class DeleteEnrollmentsFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :enrollments, :service_provider, :json
    remove_column :enrollments, :legal_basis, :json
    remove_column :enrollments, :service_description, :json
    remove_column :enrollments, :agreement, :boolean
  end
end
