class UsersController < ApplicationController

  @flash_for = {:create => 'Your profile has been created'}

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
    @user.update_attributes(params[:user])
    unless @user.errors.empty?
      render(:action => :edit)
    else
		  redirect_to(@user)
    end
	end

end
