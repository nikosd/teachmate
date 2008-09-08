class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def show
    begin
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to(:action => 'new')
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
