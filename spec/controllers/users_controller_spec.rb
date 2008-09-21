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
