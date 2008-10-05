require File.dirname(__FILE__) + '/../spec_helper'
require 'subscription_mailer'

class SubscriptionMailer
  attr_reader :number_of_mails
end

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
    @s_mailer.should have(250).subscriptions #10 + 10 from leftover
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

    new_s_mailer = SubscriptionMailer.new
    new_s_mailer.find_subscriptions(1.day.ago)
    new_s_mailer.should have(230).subscriptions 
  end

  it "should send exactly @number_of_emails unless it runs out of @search_queries" do

    UserMailer.should_receive(:deliver_search_subscription).exactly(250).times

    @s_mailer.slice(:divider => 2)
    @s_mailer.find_search_queries
    @s_mailer.mail

    last_run = @s_mailer.read_last_run
    last_run[:last_search_query].should == 2
    last_run[:mails_sent].should == 125
    last_run[:mails_left].should == 125

    new_s_mailer = SubscriptionMailer.new
    new_s_mailer.find_subscriptions(1.day.ago)
    new_s_mailer.slice(:divider => 2)
    new_s_mailer.find_search_queries
    new_s_mailer.mail

    last_run = new_s_mailer.read_last_run
    last_run[:last_search_query].should be_nil
    last_run[:mails_sent].should == 125
    last_run[:mails_left].should == 0

  end

  it "should handle increasing number of subscriptions" do

    UserMailer.should_receive(:deliver_search_subscription).any_number_of_times
    

    # run 1
    @s_mailer.slice(:divider => 3)
    @s_mailer.find_search_queries
    @s_mailer.mail

    @s_mailer.last_run[:mails_sent].should == 84
    @s_mailer.last_run[:mails_left].should == 166

    # run 2 - now adding 30 new subscriptions
    
    users = User.find(:all, :limit => 30)
    added_subscriptions = []
    users.each do |u|
      subscription = u.subscriptions.create(:search_query_id => 1).id
      if subscription
        Subscription.record_timestamps = false      
        Subscription.find(subscription).update_attribute(:updated_at, 1.day.ago - 1.minutes)
        Subscription.record_timestamps = true
      end
    end
    

    @s_mailer.find_subscriptions(1.day.ago)
    @s_mailer.slice(:divider => 3)
    @s_mailer.find_search_queries
    @s_mailer.mail

    @s_mailer.last_run[:mails_sent].should == 95
    @s_mailer.last_run[:mails_left].should == 100

  end

  after(:each) do
    File.open("#{RAILS_ROOT}/log/subscription_mailer_last_run.log", 'w').close
  end

end
