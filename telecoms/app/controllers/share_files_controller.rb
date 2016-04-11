class ShareFilesController < ApplicationController
    
    def index
        @users,@files=get_sharedfile_details() 
          
    end
    def new
       @share=ShareFile.new()
    end
    def create
      file_params=share_params
      @share=ShareFile.new(file_params) 
      
      if  @share.valid?   # run validations on it 
        file=DropboxFile.find_by(id:file_params[:file_id])  #user and file to be shared with
        user=User.find_by(id:file_params[:shared_with_id])
       
        cipher = Gibberish::RSA.new(user.public_key)  # using the public key of the user, to encrypt the key
        key=decrypt_aes_password(file)
        enc = cipher.encrypt(key)
        @share.encrypted_key=enc
        @share.save
        flash[:success] = "File shared with #{user.name}"
        redirect_to current_user
      else
          render 'new'
      end
    end
   def destroy
        
        shared_file=ShareFile.find_by(file_id: params[:id])
        shared_file.destroy
        flash[:success] = "Unshared" 
        redirect_to current_user
   end
  private
      def share_params
          params.require(:share_file).permit(:file_id, :shared_with_id)
      end
      def decrypt_aes_password(file)
        cipher = Gibberish::RSA.new(current_user.private_key)
        enc = cipher.decrypt(file.key)
        
      end
        

  
end
