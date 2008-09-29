class SearchController < ApplicationController

	helper :users

	def index
		@search = SearchQuery.new(params.merge({:logged_in => current_logged_in}))
    @search.run
    
    if @search.errors.empty?
		  @users = @search.users
      @subscription = Subscription.new
    end

	end

end
