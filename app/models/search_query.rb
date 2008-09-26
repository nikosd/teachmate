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
	
	def initialize(arg)
		require 'taggable'

		@page = arg[:page]
		self.per_page=arg[:per_page]

		# Note, I switched teach/learn tags places. This is because
		# when someone searches for users, that she can teach 'bass guitar'
		# (i.e. 'bass guitar' is typed in I_can_teach field) they actually
		# search for someone who wants to learn bass guitar and have this in their
		# I_want_to_learn field.
		@learn = Taggable::ClassMethods.split_tags_string(arg[:teach])
		@teach = Taggable::ClassMethods.split_tags_string(arg[:learn])
    super()
	end

	def run

		search_tags = Tag.find(:all, :include => [:learn_taggings],
		:conditions => ["string in (?)", (@learn+@teach)])

    @learn_tags, @teach_tags = search_tags.inject([[],[]]) do |pair, tag|
      pair[0] << tag if @learn.include?(tag.string)
      pair[1] << tag if @teach.include?(tag.string)
      pair
    end
      
		@learn_tags.uniq!
		@teach_tags.uniq!

		@teach_users = 
		@teach_tags.inject('') do |users, next_tag|

		  if users.empty?: teach_taggings_query = ''
			else users_query = ' AND teach_taggings.user_id in (:users)'
			end

			User.find(:all, :include => [:teach_taggings],
			:conditions => ["teach_taggings.tag_id = :next_tag#{users_query}",
			{:next_tag => next_tag, :users => users}]
			)
		end

		@users 	= User.paginate(:all,
						:page => @page, :per_page => @per_page,
						:include => [:teach_taggings, :learn_taggings],
						:conditions => 
						["teach_taggings.user_id in (:teach_users) AND learn_taggings.tag_id in (:learn_tags)",
						{:teach_users => @teach_users, :learn_tags => @learn_tags}]
						)

	  @tags = Tag.find(:all, :include => [:teach_taggings, :learn_taggings],
						:conditions => ["teach_taggings.user_id in (:users) OR learn_taggings.user_id in (:users)", 
						{:users => @users}])
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
