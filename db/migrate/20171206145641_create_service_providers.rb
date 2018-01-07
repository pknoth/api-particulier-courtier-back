class CreateServiceProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :service_providers do |t|

      t.timestamps
    end
  end
end
