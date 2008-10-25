require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscription do

  scenario :subscription, :root => false

  before(:each) do
    @user_id = User.find_by_email('email@subscription.com').id
  end

  it "should find all subscriptions with learn/teach strings for a particular user" do
    subscriptions = Subscription.find_for_user(@user_id)
    subscriptions.should have(3).elements
    subscriptions.each do |s|
      s[:learn_string].should_not be_nil
      s[:teach_string].should_not be_nil
      s[:element].should_not      be_nil
    end
  end

  it "should not allow more than 10 subscriptions for 1 user" do
    1.upto(10) do |i|
      Subscription.create(:user_id => @user_id, :search_query_id => i)
    end
    subscription = Subscription.create(:user_id => @user_id, :search_query_id => 11)
    subscription.errors.on(:user).should be 
  end

  it "should not create a subscription with the same search_query_id" do
    Subscription.create(:user_id => @user_id, :search_query_id => 1).errors.should be_empty
    Subscription.create(:user_id => @user_id, :search_query_id => 1).errors.should_not be_empty
  end

end
