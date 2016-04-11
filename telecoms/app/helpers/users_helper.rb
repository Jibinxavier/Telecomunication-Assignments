module UsersHelper
    def changeDirectory(client,path)
        @client2= DropboxClient.new(@dbsession,  ENV['DROPBOX_APP_MODE']).metadata(path)
    end
    
end
