module ActiveSupport
  module Cache
    class FileStore < Store
      attr_reader :cache_path
      
      private
        def real_file_path(name)
          puts name
          '%s/%s.cache' % [@cache_path, name.gsub('?', '.').gsub(':', '.')]
        end 

    end
  end
end

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

    unless read_fragment(:controller => 'search', :action => 'index', :learn => @search.teach_string)
      @search.run
      @users = @search.users if @search.errors.empty?
    end

	end

end
