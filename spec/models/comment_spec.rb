require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do

  scenario :comment, :root => false

  it "should find all comments and their authors" do
    comments = Comment.find_for_user(User.find_by_email('email@comment.com').id)
    comments.should have(3).elements
    comments.each { |s| s.should include(:element, :author) }
  end

end
