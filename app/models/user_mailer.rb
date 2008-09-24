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

end
