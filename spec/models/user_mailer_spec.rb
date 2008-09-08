require File.dirname(__FILE__) + '/../spec_helper'


describe UserMailer do

  it "should send confirmation email" do
    user = User.create!(
      :email      => 'email@mailer.com',
      :password   => 'jiffpass',
      :password_confirmation => 'jiffpass'
    )
    mail = UserMailer.create_signup(user)
    mail.should include_text("id: #{user.id}")
    mail.should include_text("password: jiffpass")
  end

end
