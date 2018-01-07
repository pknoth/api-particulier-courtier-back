class AddServiceProviderTypeToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :service_provider_type, :string
  end
end
