class SearchProxyController < ApplicationController

  def index

    if current_logged_in
      @user = User.find(current_logged_in)
      teach   = @user.teach_tags_string if @user.teach_tags_string
      city    = @user.city              if @user.city
      region  = @user.region            if @user.region
      country = @user.country           if @user.country
    end

    case params[:tag_type]
    when 'learn'
      redirect_to(
        :controller => 'search', :action => 'index',
        :learn => params[:tag], :teach => teach, :city  => city, :region => region, :country => country
      )
    when 'teach'
      redirect_to(
        :controller => 'search', :action => 'index',
        :teach => params[:tag], :city  => city, :region => region, :country => country
      )
    else
      render(:file => 'public/500.html')
    end
    
  end

end
