class UserMailer < ActionMailer::Base

    helper :application, :users

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
      sender_description.lstrip!

      @subject      = "Message from teachmate #{sender_description}"
      @recipients   = options[:to]
      @from         = sender.email
      @sent_on      = Time.now
      @body         = {:message => options[:body], :sender_description => sender_description, :sender => sender}
    end

    def search_subscription(options)
      
      search_query = options[:content][:search_query]
      search_query_location = "Search in: #{
        [search_query.city, search_query.region, search_query.country].join(', ')
      }\n" unless search_query.location == ',,'

      if search_query.users.size > 10
        number_of_users = 10
        users_caption = "Today we had more than 10 new users on your request.\nHere's last 10 of them:"
      else
        number_of_users = options[:content][:found_users].size
        plural = 's' if number_of_users > 1
        users_caption = "Today we had #{number_of_users} new user#{plural} on your request:"
      end

      @subject    = "Updates on you search query from TeachMate.org"
      @recipients = options[:email]
      @from       = "no-reply@teachmate.org"
      @sent_on    = Time.now
      @body       = {:search_query => {
          :learn => search_query.learn_string,
          :teach => search_query.teach_string,
          :location => search_query_location,
        },
        :users_caption => users_caption,
        :users => options[:content][:found_users],
        :number_of_users => number_of_users  
      }

    end

end
