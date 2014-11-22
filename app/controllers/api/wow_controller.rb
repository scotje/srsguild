class Api::WowController < ApplicationController
  layout false

  def realms
    if request.post? and !params[:realm].blank?
      @realms = Realm.game('worldofwarcraft').region(params[:region]).subregion(params[:subregion]).realm_type(params[:realm_type]).find(:all, :conditions => ["name LIKE ?", "%#{params[:realm]}%"], :order => 'region ASC, subregion ASC, name ASC')
    else
      @realms = Realm.game('worldofwarcraft').region(params[:region]).subregion(params[:subregion]).realm_type(params[:realm_type]).find(:all, :order => 'region ASC, subregion ASC, name ASC')
    end
    
    respond_to do |wants|
      wants.xml
      wants.html do
        case params[:as]
          when 'ul'
            render :template => '/api/wow/realms_as_ul' and return
          else 
            render :template => '/api/wow/realms' and return
        end
      end
    end
  end
end
