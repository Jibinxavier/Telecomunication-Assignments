class DropboxFile < ActiveRecord::Base
  belongs_to :user
  has_many :share_files , class_name:  "ShareFile",
                                  foreign_key: "file_id",
                                  dependent:   :destroy
  #has_many :users, through: :share_files  , class_name:  "ShareFile",   foreign_key: "file_id",  dependent:   :destroy
end
