# Order in which to execute methods:
#   .new
#   .find_subscriptions(1.day.ago)
#   .slice(:divider => 24)
#   .find_search_queries
#   .mail

class SubscriptionMailer

  attr_reader :subscriptions, :search_queries, :last_run

  def find_subscriptions
    @subscriptions = Subscription.find(:all, :conditions => ['updated_at < (?)', @interval], :order => 'updated_at')
    @subscriptions_size = @subscriptions.size
  end

  def initialize(interval)
    @interval = interval
    @start_time = Time.now
  end

  def find_search_queries
    
    #collecting unique search requests ids
    search_queries_ids = []
    @subscriptions.each do |s|
      search_queries_ids << s.search_query_id
    end
    search_queries_ids.uniq!

    @search_queries = SearchQuery.find(:all, :conditions => ['id in (?)', search_queries_ids]).compact 
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
      @last_run[:checked] = 0 if @last_run[:left] == 0
      # if number of subscriptions increased since last run
      if @last_run[:left] < @subscriptions_size
        @number_of_mails = 
        @last_run[:checked] + (@subscriptions_size - @last_run[:left])/options[:divider]
        leftover = (@subscriptions_size - @last_run[:left])%options[:divider]

      # if number of subscription stayed the same or even decreased
      else
        @number_of_mails = @last_run[:checked]
        leftover = 0
      end
      
      @number_of_mails += leftover if leftover > 0

    end
  end

  def each_message

    # Reading last_search_query if from file
    last_search_query = @last_run[:last_search_query]

    current_search_query = @search_queries.first
    @search_queries.each do |sq|
      current_search_query = sq if last_search_query == sq.id
    end if last_search_query

    mails = []
    if current_search_query

      # collecting subscriptions for current search_query
      # limiting their number to @number_of_mails  

      while mails.size < @number_of_mails

        found_users = []
        current_search_query.per_page = 10
        current_search_query.run 
        current_search_query.users.each do |u|
          found_users << u if u.created_at > @interval
        end
        
        # Each subscription with current_search_query.id triggers new element to be added to mails[] 
        subscriptions_to_delete = []
        @subscriptions.each_index do |i|
          break if mails.size >= @number_of_mails
          if @subscriptions[i].search_query_id == current_search_query.id
            mails << {
              :subscription => @subscriptions[i],
              :found_users => found_users,
              :search_query => current_search_query
            }
            subscriptions_to_delete << i
          end
          
          # This fires when there's no more subscriptions with current_search_query.id 
          # Switches to the next search_query
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
            yield(u.email, mails[i])
            Subscription.record_timestamps = false
            mails[i][:subscription].update_attribute(:updated_at, Time.now)
            Subscription.record_timestamps = true
          end
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
      :checked => mails.size,
      :left => @subscriptions_size - mails.size
    )
    
  end 

  def read_last_run
    # defaults
    @last_run = {:checked => 0, :left => 0}
    
    last_run_log = File.readlines("#{RAILS_ROOT}/log/subscription_mailer_last_run.log")
    last_run_log.each do |element|
      option = element.chomp.split(': ')
      @last_run.merge!({option[0].to_sym => option[1].to_i}) unless option.blank?
    end
    @last_run
  end

  def write_last_run(options)
    last_run_log = File.open("#{RAILS_ROOT}/log/subscription_mailer_last_run.log", 'w')
    main_log     = File.open("#{RAILS_ROOT}/log/subscription_mailer.log", 'a')

    main_log.puts "Start time: #{@start_time}"
    main_log.puts "Finish time: #{Time.now}"

    options.each do |k,v|
      if v
        last_run_log.puts "#{k}: #{v}"
        main_log.puts     "#{k}: #{v}"
        @last_run[k] = v
      end
    end    
    
    last_run_log.close
    main_log.puts('') and main_log.close
  end

end
