class Admin::SettingsController < Admin::AdminController
  
  def index
    @config = GuildConfig.find_or_create_by_guild_id(@_GUILD.id)
  end
  
  def update_all
    unless params[:config].blank?
      config = GuildConfig.find_or_create_by_guild_id(@_GUILD.id)
      
      unless config.update_attributes(params[:config])
        flash[:error] = "One or more of settings you selected was invalid. Please correct the errors and try again."
        flash[:errors] = config.errors
        redirect_to admin_settings_url and return
      end
    end
    
    unless params[:guild].blank?
      unless @_GUILD.update_attributes(params[:guild])
        flash[:error] = "One or more of settings you selected was invalid. Please correct the errors and try again."
        flash[:errors] = @_GUILD.errors
        redirect_to admin_settings_url and return
      end
    end
    
    flash[:notice] = "Guild settings successfully updated."
    redirect_to admin_settings_url(:subdomain => @_GUILD.subdomain) and return
  end
end
