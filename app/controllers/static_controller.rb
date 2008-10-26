class StaticController < ApplicationController

  def index
    begin
      @user = User.find(current_logged_in) if current_logged_in
    rescue
      @user = nil
    end
  end

  def about
  end

  def opensource
  end

end
