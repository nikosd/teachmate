class SearchController < ApplicationController

	helper :users

	def index
    @search = SearchQuery.new(params.merge({:logged_in => current_logged_in}))
    @subscription = Subscription.new
    
    unless read_fragment(:action => 'index', :part => 'search_results')
      @search.run
      @users = @search.users if @search.errors.empty?
    end

	end

end
