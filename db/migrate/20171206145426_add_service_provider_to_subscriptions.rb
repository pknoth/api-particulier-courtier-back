class AddServiceProviderToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :service_provider, :json
  end
end
