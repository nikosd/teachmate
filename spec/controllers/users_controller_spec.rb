require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  fixtures :users

  it "should redirect to user profile after creating one" do
		put 'create', :user => {:email => 'email@email.com'}
    response.should redirect_to("/users/#{assigns[:user].id}")
  end
	
	it "should redirect to user profile after updating one" do
    id = User.find(:first, :order => "id DESC")
		post 'update', :id => id, :user => {:email => 'newemail@email.com'}
		response.should redirect_to(user_url(id))
	end

  it "should show all comments to user profile" do
    Comment.should_receive(:find_for_user).once.and_return(['one', 'two', 'three'])

    id = User.find(:first, :order => "id DESC")
    post 'show', :id => id, :show_comments => true
    assigns[:comments].should have(3).elements
    response.should render_template('users/show')
  end

  it "should redirect to 404 if the user is not found" do
    post 'show', :id => 1000
    response.should render_template("#{RAILS_ROOT}/public/404.html")
  end

end

describe UsersController, "sending messages" do

  before(:each) do
    @invalid_message_mock = mock("Valid Message")
    @invalid_message_mock.should_receive(:valid?).any_number_of_times.and_return(false)
    @valid_message_mock = mock("Invalid Message")
    @valid_message_mock.should_receive(:valid?).any_number_of_times.and_return(true)
  end

  it "should render send-message page if any errors occured while sending the message" do 
    message_mock = mock('Message')
    message_mock.should_receive(:create).and_return(@invalid_message_mock)
    user_mock = mock('User')
    user_mock.should_receive(:messages).and_return(message_mock)
    User.should_receive(:find).twice.and_return(user_mock)

    session[:user] = 1
    post 'send_message', :message => {:recipient_id => 2, :body => 'well, hello'}
    response.should render_template('users/send_message')
  end

  it "should render send-message page if any errors occured while sending the message" do 
    sender = User.find(2)
    message_mock = mock('Message')
    message_mock.should_receive(:create).and_return(@valid_message_mock)
    user_mock = mock('User')
    user_mock.should_receive(:messages).and_return(message_mock)
    User.should_receive(:find).twice.and_return(user_mock, sender)

    request.env["HTTP_REFERER"] = 'http://test.host/users/1'

    session[:user] = 1
    post 'send_message', :message => {:recipient_id => 2, :body => 'well, hello'}
    response.should redirect_to('http://test.host/users/2')
  end

end
