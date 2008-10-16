class SearchController < ApplicationController

	helper :users

	def index

    @search = SearchQuery.new(params.merge({:logged_in => current_logged_in}))
    @subscription = Subscription.new

    @query_params = {
      :learn     => @search.teach_string,
      :teach     => @search.learn_string,
      :location  => @search.location,
      :page      => params[:page]
    }

    @query_params.delete(:page) if @query_params[:page].to_i == 1

    when_fragment_expired(@query_params, 1.minutes.ago) do  
      @search.run
      @users = @search.users if @search.errors.empty?
    end

	end

  private

  def when_fragment_expired(fragment, expiry_time)
    if fragment_exist?(@query_params)

      cache_file = File.join(
        *Digest::MD5.hexdigest(fragment_cache_key(fragment)
      ).scan(/(.{2})(.{2})(.{2})(.*)/)) + '.cache'

      cache_file_ctime = File.ctime("#{CACHE_FILE_PATH}/#{cache_file}")

      if cache_file_ctime < expiry_time
        expire_fragment(fragment)
        yield
      else
        @cached = true
      end

    else
      yield
    end
  end

end
