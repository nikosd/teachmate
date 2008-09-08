# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  JiffAuth.configure(
    :app_controller   => self,
    :auth_controller  => :users,
    :model            => :user,
    :captcha_on       => ['login', 'create'],
    :redirect_on      => {
      :create => :to_stored
    }
  )


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '2f2ea57c87a514eaa81f0923ab93f46e'
end
