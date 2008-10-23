require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

SubscriptionsController.class_eval do
  def should_be_captcha_validated
    true
  end
end

describe SubscriptionsController, "adding new subscription" do

  scenario :subscription, :root => false

  before(:each) do
    @user_id = User.find_by_email('email@subscription.com').id
  end

  it "should redirect to search results page if new subscription added: logged in user" do
    session[:user] = @user_id
    session[:return_to] = 'http://test.host/search?learn=subscription+learn&teach=subscription+teach'
    post 'create', :search_query => {:learn => 'subscription learn', :teach =>'subscription teach'}
    response.flash[:subscription_error].should be_nil
    response.flash[:subscription_ok].should_not be_nil
    SearchQuery.find(:first, :conditions => "learn_string = 'subscription teach'").should_not be_nil
    response.should redirect_to('http://test.host/search?learn=subscription+learn&teach=subscription+teach')
  end

  it "should render form to fill an email: unregistered user" do
    post 'create', :search_query => {:learn => 'subscription learn', :teach =>'subscription teach'}
    response.should render_template('subscriptions/quick_signup')
  end

  it "should register a new user and redirect to search results: unregistered user" do
    session[:user] = nil
    session[:return_to] = 'http://test.host/search?learn=subscription+learn&teach=subscription+teach'
    post(
      'create',
      :search_query => {
        :learn => 'subscription learn', 
        :teach =>'subscription teach'  
      },
      :user => {:email => 'controller@subscription.com'}
    )
    
    User.find_by_email('email@subscription.com').should_not be_nil
    response.session[:user].should_not be_nil
    response.should redirect_to('http://test.host/search?learn=subscription+learn&teach=subscription+teach')
  end

  it "should warn user, if he's already subscribed to that query" do
    session[:user] = @user_id
    post 'create', :search_query => {:learn => 'already subscribed'}
    post 'create', :search_query => {:learn => 'already subscribed'}
    assigns[:subscription].errors.on(:search_query_id).should be
    response.flash[:subscription_error].should be
  end

  it "should warn user, if he's email is invalid (empty)" do
    post(
      'create',
      :search_query => {:learn => 'subscription learn', :teach =>'subscription teach'},
      :user         => {:email =>''}
    )
    assigns[:user].errors.on(:email).should_not be_nil
  end

  it "should not register user unless his search query is valid" do
    session[:return_to] = 'http://test.host/search?learn=subscription+learn&city=Bad,cityname'
    post(
      'create',
      :search_query => {:learn => 'subscription learn', :city => 'Bad,cityname'},
      :user         => {:email =>'hello@email.com'}
    )
    session[:user].should be_nil
    response.should redirect_to('http://test.host/search?learn=subscription+learn&city=Bad,cityname')
  end

  it "should not subscribe user to an empty search query" do
    post(
      'create',
      :search_query => {:learn => '', :city => 'Bad,cityname'},
      :user         => {:email =>'hello@email.com'}
    )
    response.should render_template('public/403.html')
  end

  it "should display error if email is already used" do
    User.create(:email => 'email@in.use')
    post(
      'create',
      :search_query => {:learn => 'subscription learn'},
      :user         => {:email =>'email@in.use'}
    )
    assigns[:user].errors.on(:email).should_not be_nil
    response.should render_template('subscriptions/quick_signup')
  end

end

describe SubscriptionsController, "managing subscriptions" do

  before(:all) do
    Subscription.stub!(:find_for_user).and_return(%w{arr1 arr2 arr3})
  end

  it "should display a list of user subscriptions" do
    session[:user] = 1
    get 'index'
    assigns[:subscriptions].should have(3).elements
    response.should render_template('index')
  end

  it "should not delete a subscription that does not belong to the user" do
    subscription = mock("subscription to delete")
    subscription.should_receive(:user_id).once.and_return(2)
    Subscription.should_receive(:find).once.and_return(subscription)

    request.env["HTTP_REFERER"] = 'http://test.host/subscriptions'
    session[:user] = 1
    
    post 'destroy', :subscription => {:id => 2}
    flash[:error].should_not be_nil
  end

end
