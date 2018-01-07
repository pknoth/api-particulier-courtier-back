class CreateDocumentTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :document_types do |t|
      t.string :name
      t.string :human_name
      t.integer :enrollment_id

      t.timestamps
    end
  end
end
