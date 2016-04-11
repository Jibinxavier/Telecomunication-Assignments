class ShareFile < ActiveRecord::Base
    belongs_to :user
    belongs_to :dropbox_file
    validates :shared_with_id,:file_id, presence: true
    validates_uniqueness_of  :file_id, :scope => [:shared_with_id, :file_id],message: " is already shared with this person "
    
end
