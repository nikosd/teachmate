namespace(:subscription) do

  RAILS_ENV = 'development' unless RAILS_ENV
  require File.dirname(__FILE__) + '/../../config/environment'
  require 'subscription_mailer'

  task :mail do
    mailer = SubscriptionMailer.new(1.day.ago)

    mailer.find_subscriptions
    mailer.slice(:divider => 24)
    mailer.find_search_queries
    mailer.each_message do |email, content|
      UserMailer.deliver_search_subscription(
        :email => email,
        :content => content
      ) unless content[:found_users].empty?
    end

    puts "Checked this time: #{mailer.last_run[:checked]}"
  end

end
