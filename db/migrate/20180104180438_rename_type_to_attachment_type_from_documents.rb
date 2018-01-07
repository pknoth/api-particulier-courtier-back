class RenameTypeToAttachmentTypeFromDocuments < ActiveRecord::Migration[5.1]
  def change
    rename_column :documents, :type, :attachment_type
  end
end
