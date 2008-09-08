require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController, "with valid params" do

  fixtures :users

  before(:all) do
    Comment.delete_all
  end

  before(:each) do
    session[:user] = 2
  end

  it "create new comment" do
    post 'create', :comment => {:body => 'This is my comment', :user_id => 1}
    response.should redirect_to('http://test.host/users/1?show_comments=true#comment_' + assigns[:comment].id.to_s)
  end

  it "should update the body of existing comment if current_logged_in == author_id" do
    comment = Comment.create(:body => 'This is comment body', :author_id => 2, :user_id => 1)
    post 'update', :comment => {:id => comment.id, :body => 'This is my comment'}
    response.should redirect_to('http://test.host/users/1?show_comments=true#comment_' + assigns[:comment].id.to_s)
  end

end

describe CommentsController, "with invalid params" do

  fixtures :users

  it "should not allow to create comment for unlogged in user" do
    session[:user] = nil
    post 'create', :comment => {:body => 'This is my comment', :user_id => 1}
    response.should redirect_to('/login')
  end

  it "should not allow to edit comment if the user is not it's author" do
    session[:user] = 1
    comment = Comment.create(:body => 'This is comment body', :author_id => 2, :user_id => 1)
    post 'update', :comment => {:id => comment.id, :body => 'This is my comment'}
    response.should render_template('users/error.erb')
  end

  it "should not allow comments with empty body" do
    session[:user] = 1
    post 'create', :comment => {:user_id => 2}
    flash[:err_message].should_not be_nil
  end

  it "should not allow comments to your own profile" do
    request.env["HTTP_REFERER"] = 'http://test.host/users/1'
    session[:user] = 1
    post 'create', :comment => {:body => 'This is my comment', :user_id => 1}
    flash[:err_message].should_not be_nil 
  end

end
