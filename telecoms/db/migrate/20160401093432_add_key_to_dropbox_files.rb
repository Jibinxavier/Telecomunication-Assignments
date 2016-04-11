class AddKeyToDropboxFiles < ActiveRecord::Migration
  def change
    add_column :dropbox_files, :key, :string
  end
end
