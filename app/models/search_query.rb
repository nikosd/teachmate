# For now it works like this:
# 1) You pass a joined tags string, the method splits it, then
# 2) finds all tags' ids (both learn and teach - then splits this arr into two:
# 	 @learn_tags & @teach_tags)
# 3) performs a number of queries which eventually find only those users who have all
# 	 of the given teach_tags and not just one
# 4) searches for users that contain both learn & teach tags' ids
# 5) searches for tags, that all found users have
class SearchQuery < ActiveRecord::Base

  has_many :subscriptions
	attr_reader :users, :learn_tags, :teach_tags, :tags, :per_page

	def per_page=(number)
		begin
			number = Integer(number)
			@per_page = number
			raise ArgumentError if number.nil? || number > 50 || number < 5
		rescue
			@per_page = 10
		end
	end

	# Inputs:
	# 1. learn, teach, location
	# 2. learn, teach, a, b, c
	# 3. 
	def initialize(options)
		require 'taggable'

    learn, teach, location = options[:learn], options[:teach], options[:location]
    
    if options[:a]
      #...
    end

		@page = options[:page]
		self.per_page = options[:per_page]

		# Note, I switched teach/learn tags places. This is because
		# when someone searches for users, that she can teach 'bass guitar'
		# (i.e. 'bass guitar' is typed in I_can_teach field) they actually
		# search for someone who wants to learn bass guitar and have this in their
		# I_want_to_learn field.
		@learn = Taggable::ClassMethods.split_tags_string(options[:teach])
		@teach = Taggable::ClassMethods.split_tags_string(options[:learn])
    super()
	end

	def run

    errors.add(:learn, "Too many tags") and return if @teach.length > 3
    errors.add(:teach, "Too many tags") and return if @learn.length > 15

		search_tags = Tag.find(:all, :include => [:learn_taggings],
		:conditions => ["string in (?)", (@learn+@teach)])

    @learn_tags, @teach_tags = search_tags.inject([[],[]]) do |pair, tag|
      pair[0] << tag if @learn.include?(tag.string)
      pair[1] << tag if @teach.include?(tag.string)
      pair
    end

    # If one of teach_tags is not found in the tag table, it means that
    # there's no such user with it an, therefore the search result
    # should be empty
    @users = [] and return if @teach_tags.length < @teach.length
      
    @learn_tags.uniq!
    @teach_tags.uniq!

    unless @teach_tags.empty? #Unless user left "I want to learn" blank
      @teach_users = 
      @teach_tags.inject('') do |users, next_tag|

        if users.empty?: users_query = ''
        else users_query = ' AND teach_taggings.user_id in (:users)'
        end


        find_params = {
          :include => [:teach_taggings],
          :conditions => ["teach_taggings.tag_id = :next_tag#{users_query}",
          {:next_tag => next_tag, :users => users}]
        }

        if @learn_tags.empty?
          User.paginate(:all, find_params.merge({:page => @page, :per_page => @per_page}))
        else
          User.find(:all, find_params)
        end
      end

      @tags  = @teach_tags
      @users = @teach_users 
      teach_taggings_condition = "teach_taggings.user_id in (:teach_users) AND "

    end
    

    unless @learn_tags.empty? #Unless user left "I can teach" blank
      @users 	= User.paginate(:all,
              :page => @page, :per_page => @per_page,
              :include => [:teach_taggings, :learn_taggings],
              :conditions => 
              ["#{teach_taggings_condition}learn_taggings.tag_id in (:learn_tags)",
              {:teach_users => @teach_users, :learn_tags => @learn_tags}]
              )
      @tags = @learn_tags
    end

    unless @teach_tags.empty? and @learn_tags.empty?
      @tags = Tag.find(:all, :include => [:teach_taggings, :learn_taggings],
              :conditions => ["teach_taggings.user_id in (:users) OR learn_taggings.user_id in (:users)", 
              {:users => @users}])
    else
      errors.add_to_base("Search query can't be blank")
    end

	end

  def store_query
    #switching learn/teach tags again to save the query
    self.learn_string = @teach.sort.join(", ")
    self.teach_string = @learn.sort.join(", ")
    if found_query = self.class.find(
      :first,
      :conditions => ['learn_string = (?) and teach_string = (?)', self.learn_string, self.teach_string]
    ) then
      self.id = found_query.id
    else
      self.save
    end
  end

end
