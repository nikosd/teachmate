class SearchController < ApplicationController

	helper :users

	def index
		@search = SearchQuery.new(params)
    @search.run
    
    if @search.errors.empty?
		  @users = @search.users
      @subscription = Subscription.new
    end

	end

end
