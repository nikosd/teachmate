require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do

  scenario :message, :root => false

  before(:each) do
    @sender_with_email       = User.find_by_first_name('sender with email')
    @recipient_with_email    = User.find_by_first_name('recipient with email')
    @sender_without_email    = User.find_by_first_name('sender without email')
    @recipient_without_email = User.find_by_first_name('recipient without email')
  end

  it "should send message to the user" do
    UserMailer.should_receive(:deliver_user_message).once

    message = @sender_with_email.messages.create(
      :recipient_id => @recipient_with_email.id,
      :body => "Hello, this is our tiny little message from test 1"
    )
  end

  it "should not save and send message if less than 10 minutes passed since last message was sent" do
    UserMailer.should_receive(:deliver_user_message).once
    message = @sender_with_email.messages.create(
      :recipient_id => @recipient_with_email.id,
      :body => "Hello, this is our tiny little message"
    )

    message.errors.should be_empty

    new_message = @sender_with_email.messages.create(
      :recipient_id => @recipient_with_email.id,
      :body => "Hello, this is our tiny little message"
    )
    new_message.errors.on_base.should be

  end

  it "should not send and save message if sender doesn't have email" do
    message = @sender_without_email.messages.create(
      :recipient_id => @recipient_with_email.id,
      :body => "Hello, this is our tiny little message"
    )
    message.errors.on_base.should be
  end

  it "should not send and save message if recipient doesn't have email" do
    message = @sender_with_email.messages.create(
      :recipient_id => @recipient_without_email.id,
      :body => "Hello, this is our tiny little message"
    )
    message.errors.on_base.should be
  end

end
