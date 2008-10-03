require File.dirname(__FILE__) + '/../spec_helper'


describe UserMailer do

  it "should send password recover token" do
    sender = User.create(:email => 'lost_password@mailer.com')
    message = UserMailer.create_lost_password(sender)
    #p message.encoded
  end

  it "should send message from user to user" do
    sender = User.create(:email => 'mailer@mailer.com')
    message = UserMailer.create_user_message(:sender => sender, :to => 'mailer@model.com', :body => 'well, hello')
    #p message.encoded
  end

end
