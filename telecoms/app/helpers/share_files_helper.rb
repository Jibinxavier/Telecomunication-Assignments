module ShareFilesHelper
    def get_sharedfile_details()
        user_files=DropboxFile.where(user_id:current_user.id)# get all users files
      
        shared_files=ShareFile.where(file_id: user_files.pluck(:id))# get files that are shared
           
        if shared_files!=[]
            shared_with=User.where(id: shared_files.pluck(:shared_with_id))# users with whom the file is shared
          
            files=[]
            shared_files.each{|x|files.concat([get_file_info(user_files,x.file_id)]) } # converting into hash and extracting files shared. This is to 
                                                                                            #get the name and id
              
            shared_with=shared_with.map{|x| x.attributes} #converting to hash
        
            return shared_with,files
        else
            return [],[]
        end
        
    end
    def get_file_info(user_files,id)
        
        user_files.each do |file|
            if file['id']==id
               return file.attributes
            end
        end
         
        return []
    end
end
