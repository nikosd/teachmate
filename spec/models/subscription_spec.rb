require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscription do

  scenario :subscription, :root => false

  it "should find all subscriptions with learn/teach strings for a particular user" do
    subscriptions = Subscription.find_for_user(User.find_by_email('email@subscription.com').id)
    subscriptions.should have(3).elements
    subscriptions.each { |s| s.should include(:learn_string, :teach_string, :element) }
  end

end
