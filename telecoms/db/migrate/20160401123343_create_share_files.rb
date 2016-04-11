class CreateShareFiles < ActiveRecord::Migration
  def change
    create_table :share_files do |t|
   
      t.integer :shared_with_id
      t.integer :file_id
      t.string :encrypted_key

      t.timestamps null: false
    end
     add_index :share_files, :file_id
     add_index :share_files, :shared_with_id
    add_index :share_files, [:file_id, :shared_with_id], unique: true
  end
end
