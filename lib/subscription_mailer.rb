class SubscriptionMailer

  attr_reader :subscriptions, :search_queries, :last_run

  def find_subscriptions(time_ago)
    @subscriptions = Subscription.find(:all, :conditions => ['updated_at < (?)', time_ago], :order => 'updated_at')
    @subscriptions_size = @subscriptions.size
  end

  def find_search_queries
    
    #collecting unique search requests ids
    search_queries_ids = []
    @subscriptions.each do |s|
      search_queries_ids << s.search_query_id
    end
    search_queries_ids.uniq!

    @search_queries = SearchQuery.find(:all, :conditions => ['id in (?)', search_queries_ids]).compact 
#     @search_queries.each {|sq| sq.per_page=10; sq.run; sq}
  end

  def slice(options)
    read_last_run
    
      if @subscriptions_size > 0
      # n1      - subscriptions that were fired on previous run
      # m1      - what's left of previous run
      # n2      - subscriptions we're going to fire this time
      # m2      - total subsciptions this time
      # divider - the number we divide all subscriptions for
      #
      # The following code says this:
      #   
      #   if m1 < m2
      #     new = m2 - m1
      #     n2 = n1 + (new/divider)
      #   else
      #     n2 = n1
      #   end
      #
      # This way we always stay updated and fire as much mails
      # as we currently need.
      @last_run[:mails_sent] = 0 if @last_run[:mails_left] == 0
      # if number of subscriptions increased since last run
      if @last_run[:mails_left] < @subscriptions_size
        @number_of_mails = 
        @last_run[:mails_sent] + (@subscriptions_size - @last_run[:mails_left])/options[:divider]
        leftover = (@subscriptions_size - @last_run[:mails_left])%options[:divider]

      # if number of subscription stayed the same or even decreased
      else
        @number_of_mails = @last_run[:mails_sent]
        leftover = 0
      end
      
      @number_of_mails += leftover if leftover > 0

    end
  end

  def mail

    # Reading last_search_query if from file
    last_search_query = @last_run[:last_search_query]

    current_search_query = @search_queries.first
    @search_queries.each do |sq|
      current_search_query = sq if last_search_query == sq.id
    end if last_search_query
    current_search_query.run

    # collecting subscriptions for current search_query
    # limiting their number to @number_of_mails
    mails = []

    while mails.size < @number_of_mails

      # if there's no more subscriptions for the current searchquery
      # switch to the next query
      subscriptions_to_delete = []
      @subscriptions.each_index do |i|
        break if mails.size >= @number_of_mails
          if @subscriptions[i].search_query_id == current_search_query.id
            mails << {:subscription => @subscriptions[i], :results => current_search_query.users}
            subscriptions_to_delete << i
          end
        
        # this fires on the last run
        if i == @subscriptions.size - 1
          @search_queries.delete(current_search_query)
          current_search_query = @search_queries.first
          subscriptions_to_delete.each { |index| @subscriptions.delete_at(index) }
        end
      end

      break if @subscriptions.empty?
    end


    # collecting users for all mails
    user_ids = []
    mails.each { |m| user_ids <<  m[:subscription].user_id }
    users = User.find(:all, :conditions => ['id in (?)', user_ids])
    
    # adding user models to mails' each element's hash
    mails.each_index do |i|
      users.each do |u|
        if u.id == mails[i][:subscription].user_id
          #puts "Sending search results to #{u.email}"
          UserMailer.deliver_search_subscription(
            :user => u, :results => mails[i][:results]
          )
          Subscription.record_timestamps = false
          mails[i][:subscription].update_attribute(:updated_at, Time.now)
          Subscription.record_timestamps = true
        end
      end
    end

    if current_search_query
      last_search_query = current_search_query.id
    else
      last_search_query = nil
    end
    write_last_run(
      :last_search_query => last_search_query,
      :mails_sent => mails.size,
      :mails_left => @subscriptions_size - mails.size
    )

  end 

  def read_last_run
    # defaults
    @last_run = {:mails_sent => 0, :mails_left => 0}
    
    last_run_log = File.readlines("#{RAILS_ROOT}/log/subscription_mailer_last_run.log")
    last_run_log.each do |element|
      option = element.chomp.split(': ')
      @last_run.merge!({option[0].to_sym => option[1].to_i}) unless option.blank?
    end
    @last_run
  end

  def write_last_run(options)
    file = File.open("#{RAILS_ROOT}/log/subscription_mailer_last_run.log", 'w')
    options.each do |k,v|
      if v
        file.puts "#{k}: #{v}";
        @last_run[k] = v
      end
    end
    file.close
  end

end
