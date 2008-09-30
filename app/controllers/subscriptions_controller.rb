class SubscriptionsController < ApplicationController

  validates_captcha

  before_filter :set_return_to, :except => [:create]
  before_filter :should_be_logged_in, :only => [:index]

  def create
    if request.post?
      @subscription = Subscription.new
      if params[:user] && current_logged_in.nil?
        return(false) unless(should_be_captcha_validated)
        user = User.create(params[:user])
        if user.email
          session[:user] = user.id
        else
          flash[:warning] = "You're email is invalid"
        end
      end

      if current_logged_in
        query = SearchQuery.new(params[:search_query])
        query.store_query
        # I wish I could detect errors when writing 'query.subscriptions << subscription'
        subscription = Subscription.create(:user_id => current_logged_in, :search_query_id => query.id)

        unless subscription.errors.empty?
          flash[:subscription_error] = "You've already subscribed to that search query."
        else 
          flash[:subscription_ok] = "Done, we'll be sending you updates every day."
        end

        redirect_to_stored
      end

      unless current_logged_in  
        @city    = params[:search_query][:city] 
        @region  = params[:search_query][:region]
        @country = params[:search_query][:country]
        @teach   = params[:search_query][:teach]
        @learn   = params[:search_query][:learn]
        render(:template => "subscriptions/quick_signup")
      end
    end
  end

  def index
    @subscriptions = Subscription.find_for_user(current_logged_in)
  end

  def destroy
    Subscription.delete(params[:id])
    flash[:message] = "The subscription was removed."
    redirect_to :back
  end

  private

  def should_be_captcha_validated
    unless captcha_validated?
      flash[:warning] = "Sorry, the letters you entered don't match the ones on the picture, try again"
      render(:template => "subscriptions/quick_signup") and return false
    end
    return true
  end

end
