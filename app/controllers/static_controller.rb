class StaticController < ApplicationController

  def index
    @user = User.find(current_logged_in) if current_logged_in
  end

  def about
  end

end
