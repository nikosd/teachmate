class UserMailer < ActionMailer::Base

    def signup(user)
      @subject      = "Signup confirmation"
      @recipients   = user.email
      @from         = "no-reply@teachmate.org"
      @sent_on      = Time.now
      @body         = {:id => user.id, :password => user.password}
    end

    def lost_password(user)
      @subject      = "Recover password"
      @recipients   = user.email
      @from         = "no-reply@teachmate.org"
      @sent_on      = Time.now
      @body         = {:token => user.password_token}
    end

end
