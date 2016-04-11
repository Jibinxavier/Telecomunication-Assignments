require 'dropbox_sdk'
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :dropbox_session_deserialize, only: [:show, :upload, :search, :dropbox_path_change, :dropbox_download]

  def dropbox_session_deserialize
    if current_user.dropbox_session
      @dropbox = current_user.dropbox_session if current_user.dropbox_session
      @dbsession = DropboxSession.deserialize(current_user.dropbox_session)
    end
  end
  def show
    @user = User.find(params[:id])
    @dropbox = current_user.dropbox_session if current_user.dropbox_session
    
     #First, find the dashboard, then find the current user's dropbox_session from the database
     if current_user.dropbox_session
     dbsession = DropboxSession.deserialize(current_user.dropbox_session)
     # create the dropbox client object
     @client = DropboxClient.new(dbsession, ENV['DROPBOX_APP_MODE']).metadata('/')
     end
    
  end
   
  
  def upload
    client = DropboxClient.new(@dbsession,  ENV['DROPBOX_APP_MODE'])
    # Upload the POST'd file to Dropbox, keeping the same name
    key=SecureRandom.base64(45)        # generating random password for AES
    cipher = Gibberish::RSA.new(current_user.public_key)# encrypting the password with public key of the user
    enc_key = cipher.encrypt(key)
    
    
    cipher = Gibberish::AES.new(key)
 
    encryp_file=cipher.encrypt( params[:file].read)# encrypting the file
    resp = client.put_file("#{params[:path]}/#{params[:file].original_filename}",encryp_file) #uploading the file to dropbox
     @client = client.metadata(params[:path])
    
    current_user.dropbox_files.create(path:resp['path'],key:enc_key) # adding the encrypted symmetric key to the database 
    
    flash[:success]="Successfully uploaded"
    redirect_to current_user
    
  end
  
 
   
  
  def dropbox_download
    
    user=current_user
    file,meta=DropboxClient.new(@dbsession,  ENV['DROPBOX_APP_MODE']).get_file_and_metadata(params[:path]) 
    key=get_key(meta,user)
    decryp_file=file
     
    if key
      cipher = Gibberish::AES.new(key)
      decryp_file=cipher.decrypt( file)
    end
    
    send_data decryp_file, filename: meta['path'][1..-1]
    
    
  end
    
  
  ########################
   def index
     @users = User.paginate(page: params[:page])
  end

  def create
    kp= Gibberish::RSA.generate_keypair()
    @user = User.new(user_params)
    @user.public_key=kp.public_key.to_s
    @user.private_key=kp.private_key.to_s
    
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the telecoms"
      redirect_to @user
    else
      render 'new'
    end
  end
  def new
    @user = User.new
  end
  def edit 
    @user=User.find(params[:id])
  end
   
  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      
      redirect_to @user
    else
      render 'edit'
    end
  end
   
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    
      # Confirms a logged-in user.
   

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    def get_key(metadata,user)
      file =current_user.dropbox_files.find_by(path: metadata['path'] )  
      shared_file_key=ShareFile.find_by(shared_with_id: current_user.id)
     
      if file!=[] and file!=nil # if the file being decrypted  by the owner 
        return  decrypt_aes_password(user.private_key,file.key)
      elsif shared_file_key!=[] and shared_file_key!=nil # if the file is being decrypted by a member in the group
       
        return decrypt_aes_password(user.private_key,shared_file_key.encrypted_key)
      else
        return nil
      end
    end
     
    def decrypt_aes_password(private_key,encrypted_key)
      cipher = Gibberish::RSA.new(private_key)
      enc = cipher.decrypt(encrypted_key)
    end
    
end