require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  it "should redirect to user profile after creating one" do
    request.env['HTTP_REFERER'] = '/users/new'
		post 'create', :params => {:user => {:email => 'email@email.com'}}
    response.should redirect_to('/users/new')
  end
	
	it "should redirect to user profile after updating one" do
    id = User.find(:first, :order => "id DESC")
		post 'update', :id => id, :params => {:user => {:email => 'newemail@email.com'}}
		response.should redirect_to(user_url(id))
	end

  it "should show all comments to user profile" do
    Comment.should_receive(:find_for_user).once.and_return(['one', 'two', 'three'])

    id = User.find(:first, :order => "id DESC")
    post 'show', :id => id, :show_comments => true
    assigns[:comments].should have(3).elements
    response.should render_template('users/show')
  end

end
