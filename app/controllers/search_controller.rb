class SearchController < ApplicationController

	helper :users

	def index
		@search = SearchQuery.new(params)
    @search.run
		@users = @search.users

    @subscription = Subscription.new
	end

end
