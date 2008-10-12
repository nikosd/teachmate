class SearchController < ApplicationController

	helper :users

	def index

    @search = SearchQuery.new(params.merge({:logged_in => current_logged_in}))
    @subscription = Subscription.new

    @query_params = {
      :learn => @search.teach_string,
      :teach => @search.learn_string,
      :location  => @search.location
    }

    unless read_fragment(@query_params)
      @search.run
      @users = @search.users if @search.errors.empty?
    end

	end

end
