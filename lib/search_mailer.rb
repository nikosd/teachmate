module Teachmate
  class SearchMailer
    attr_accessor :last_search_file, :max_subscriptions
    DEFAULT_LSF = "config/lsf"
    DEFAULT_MAX_SUBS = 1000
    def initialize(options)
      @last_search_file = options[:last_search_file] || DEFAULT_LSF
      @limit = options[:max_subscriptions] || DEFAULT_MAX_SUBS
      
      @last_index = File.open(@last_search_file){|f| f.read }.to_i
      
    end
    
    def run
      
      s = Subscription.find(:all, :limit => @limit, :conditions => ["id > ?", @last_index], :include => "")
      
    end
  end
end
