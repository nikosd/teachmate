class UserMailer < ActionMailer::Base

    def signup(user)

    end

    def lost_password(user)
      @subject      = "Recover password"
      @recipients   = user.email
      @from         = "no-reply@teachmate.org"
      @sent_on      = Time.now
      @body         = {:token => user.password_token}
    end

    def user_message(options)
      sender = options[:sender]
      
      sender_description = ''
      sender_description  += " #{sender.first_name}" if sender.first_name
      sender_description  += " #{sender.last_name}"  if sender.last_name
      sender_description  += " id ##{sender.id}"     if sender.first_name.blank? and sender.last_name.blank?

      @subject      = "Message from teachmate #{sender_description}"
      @recipients   = options[:to]
      @from         = sender.email
      @sent_on      = Time.now
      @body         = {:message => options[:body], :sender_description => sender_description, :sender => sender}
    end

    def search_subscription(options)
      puts "Okay, delivering mail here"
    end

end
