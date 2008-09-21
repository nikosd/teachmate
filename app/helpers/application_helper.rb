# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
    def auth_link
      if(self.current_logged_in.nil?)
        return link_to("Login", '/login') + " or " + link_to("Create Profile", "/users/new")
      else
        return link_to("Profile", "/#{jiff_auth_options(:controller)}/#{self.current_logged_in}")
      end
    end

end
