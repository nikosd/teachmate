class CommentsController < ApplicationController

  before_filter :should_be_logged_in, :only => [:create, :update]

  def create
    
    if current_logged_in == params[:comment][:user_id].to_i
      flash[:err_message] = "You can't leave comments in your own profile"
      anchor = '#comment_form'
    else

      @comment = Comment.new(:body => params[:comment][:body], :author_id => current_logged_in)
      @receiver = User.find(params[:comment][:user_id])
      @receiver.comments << @comment 

      unless @comment.errors.empty?
        flash[:err_message] = "You can't post an empty comment"
        anchor = '#comment_form'
      else
        anchor = '#comment_' + @comment.id.to_s
      end

    end

    redirect_to("/users/#{params[:comment][:user_id]}?show_comments=true#{anchor}")
  end

  def update
    @comment = Comment.find(params[:comment][:id])
    if @comment.author_id == current_logged_in
      if params[:comment][:body].empty?
        @comment.destroy
      else
        @comment.update_attribute(:body, params[:comment][:body])
      end
      redirect_to("/users/#{@comment.user_id}?show_comments=true\#comment_#{@comment.id}")
    else
      flash[:err_message] = "You don't have permission to edit this comment"
      render(:template => 'users/error.erb')
    end
  end

end
