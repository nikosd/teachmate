class UsersController < ApplicationController

  def new
    @user = User.new
    @title = "Create new account"
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render(:file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found") and return
    end
    @comments = Comment.find_for_user(@user.id)
    @new_comment  = Comment.new
  end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		redirect_to(@user) if @user.update_attributes(params[:user])
	end

end
