class User < ActiveRecord::Base

	require 'taggable'
  require 'avatars'

	has_many	:teach_taggings
	has_many  :learn_taggings
  has_many  :teach_tags, :through => :teach_taggings, :source => :tag
  has_many  :learn_tags, :through => :learn_taggings, :source => :tag
  has_many  :subscriptions
  has_many  :comments

	acts_as_taggable
  include Avatars

  # all validations here please
  validates_date :birthdate, :before => Proc.new {Time.now.years_ago(5).to_date}, :after => '1 Jan 1900', :allow_nil => true
  
  validates_uniqueness_of :email, :allow_nil => true
  validate                :validate_tags_string, :validate_tags, :validate_email
  validates_length_of     :more_info,  :maximum => 10240, :allow_nil => true
  validates_length_of     :notes,      :maximum => 100, :allow_nil => true

  [:email, :first_name, :last_name, :city, :region, :country].each do |field|
    validates_length_of field, :maximum => 32, :allow_nil => true
  end

  [:city, :region, :country].each do |field|
    validates_format_of field, :with => /\A[^,]+\Z/, :allow_blank => true
  end

  before_save :set_status, :downcase_location
	after_save  :save_learn_tags, :save_teach_tags

	#	here we make sure all empty? params are replaced by nils
	def before_validation
		[:first_name, :last_name, :city, :region, :country, :more_info, :openid, :notes, :email].each do |param|
			self.send("#{param.to_s}=", nil) if !self.send(param.to_s).nil? && self.send(param.to_s).empty?
		end
	end

	def learn_tags_string=(t)
		@learn_tags_string = t if t
    if t and t.length < 2000
      @learn_tags_string.chars.downcase!
      @learn_tags_collection = split_tags_string(@learn_tags_string)
      @learn_tags_collection.uniq!
    end
	end

	def teach_tags_string=(t)
		@teach_tags_string = t if t
    if t and t.length < 2000
      @teach_tags_string.chars.downcase! 
      @teach_tags_collection = split_tags_string(@teach_tags_string)
      @teach_tags_collection.uniq!
    end
	end

	def learn_tags_string
		join_tags_to_string(self.learn_tags)
	end

	def teach_tags_string
		join_tags_to_string(self.teach_tags)
	end


  def city
    read_attribute(:city).chars.capitalize if read_attribute(:city)
  end
  def country
    read_attribute(:country).chars.capitalize if read_attribute(:country)
  end


	private

  def validate_email
    if (!email.blank?)
      unless email =~ /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
        errors.add(:email, 'is invalid')
      end
    end
  end

  def validate_tags_string
    if @teach_tags_string
      errors.add(
        :teach_tags_string, "Too long, no more than 2000 characters allowed"
      ) if @teach_tags_string.length > 2000
    end
    if @learn_tags_string
      errors.add(
        :learn_tags_string, "Too long, no more than 2000 characters allowed"
      ) if @learn_tags_string.length > 2000
    end
  end

  def validate_tags
    errors.add(
      :teach_tags_string, "Too many tags, no more than 100 tags allowed"
    ) if @teach_tags_collection and @teach_tags_collection.length > 100
    errors.add(
      :learn_tags_string, "Too many tags, no more than 100 tags allowed"
    ) if @learn_tags_collection and @learn_tags_collection.length > 100
  end

  def downcase_location
    [:city, :region, :country].each do |attribute|
      write_attribute(attribute, read_attribute(attribute).chars.downcase) if read_attribute(attribute)
    end
  end

  def set_status
    if @teach_tags_string and @learn_tags_string
      if @teach_tags_string.empty? and @learn_tags_string.empty?
        self.status = 'disabled' 
      else 
        self.status = nil
      end
    end
  end

	def save_learn_tags
    if @learn_tags_collection
      self.learn_taggings.delete_all 
		  self.learn_tags << @learn_tags_collection.map {|t| Tag.find_or_create_by_string(t)}
    end
	end

	def save_teach_tags
    if @teach_tags_collection
      self.teach_taggings.delete_all 
		  self.teach_tags << @teach_tags_collection.map {|t| Tag.find_or_create_by_string(t)}
    end
	end


end
