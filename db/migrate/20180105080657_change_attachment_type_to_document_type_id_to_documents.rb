class ChangeAttachmentTypeToDocumentTypeIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    rename_column :documents, :attachment_type, :document_type_id
    change_column :documents, :document_type_id, "integer USING document_type_id::integer"
  end
end
