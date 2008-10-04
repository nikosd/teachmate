require File.dirname(__FILE__) + '/../spec_helper'
require 'subscription_mailer'

describe SubscriptionMailer do

  scenario :subscription_mailer, :root => false

  before(:each) do

    # Just updating updated_at field manually
    Subscription.record_timestamps = false
    subscriptions = Subscription.find(:all)
    subscriptions.inject(1) do |i, sub|
      if sub.search_query_id < 3
        sub.update_attribute(:updated_at, 1.day.ago - i.minutes)
      else
        sub.update_attribute(:updated_at, Time.now)
      end
      i+1
    end

    @s_mailer = SubscriptionMailer.new 
    @s_mailer.find_subscriptions(1.day.ago)
  end

  it "should find all subscriptions that were updated more than 1 day ago" do
    @s_mailer.should have(250).subscriptions
  end

  it "should slice the oldest subscriptions" do
    oldest_before_slice = @s_mailer.subscriptions.first
    @s_mailer.slice(:divider => 24)
    @s_mailer.should have(20).subscriptions #10 + 10 from leftover
    @s_mailer.subscriptions.first.should == oldest_before_slice
  end

  it "should find requests for those subscriptions" do
    @s_mailer.slice(:divider => 24)
    @s_mailer.find_search_queries
    @s_mailer.should have(2).search_queries
    
    users = User.find(:all, :conditions => ["first_name = (?)", 'regular_user'])

  end

  it "should mail results to users" do
    UserMailer.should_receive(:deliver_search_subscription).exactly(20).times

    @s_mailer.slice(:divider => 24)
    @s_mailer.find_search_queries
    @s_mailer.mail
  end

end
