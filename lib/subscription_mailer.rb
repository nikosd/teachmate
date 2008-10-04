class SubscriptionMailer

  attr_reader :subscriptions, :search_queries

  def find_subscriptions(time_ago)
    @subscriptions = Subscription.find(:all, :conditions => ['updated_at < (?)', time_ago], :order => 'updated_at')
  end

  def find_search_queries
    
    #collecting unique search requests ids
    search_queries_ids = []
    @subscriptions.each do |s|
      search_queries_ids << s.search_query_id
    end
    search_queries_ids.uniq!

    @search_queries = SearchQuery.find(:all, :conditions => ['id in (?)', search_queries_ids]).compact 
    @search_queries.each {|sq| sq.per_page=10; sq.run; sq}
  end

  def slice(options)
    number_of_mails = @subscriptions.size/options[:divider]
    leftover = @subscriptions.size%options[:divider]
    number_of_mails += leftover if leftover > 0

    @subscriptions = @subscriptions.slice(0..number_of_mails-1)
  end

  def mail
    @subscriptions.each do |s|
      found_users = nil
      @search_queries.each do |sq|
        if sq.id == s.search_query_id
          found_users = sq.users
          break
        end
      end
      UserMailer.deliver_search_subscription(found_users) unless found_users.blank?
    end
  end


end
