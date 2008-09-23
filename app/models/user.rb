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
  validates_date :birthdate, :before => Proc.new {Time.now.years_ago(7).to_date}, :after => '1 Jan 1900', :allow_nil => true
  # TODO: this breaks spec for some unknown reasons. It somehow re-fills the fields,
  # that where changed from empty to nil. If remove the next line, it works ok.
  # validates_length_of :notes, :maximum => 100
  
  validates_uniqueness_of :email, :allow_nil => true
  validate_on_create      :validate_email
  validate_on_update      :validate_email

  validates_length_of     :email,      :maximum => 32, :allow_nil => true
  validates_length_of     :first_name, :maximum => 32, :allow_nil => true
  validates_length_of     :last_name,  :maximum => 32, :allow_nil => true
  validates_length_of     :city,       :maximum => 32, :allow_nil => true
  validates_length_of     :region,     :maximum => 32, :allow_nil => true
  validates_length_of     :country,    :maximum => 32, :allow_nil => true
  validates_length_of     :more_info,  :maximum => 10240, :allow_nil => true
  validates_length_of     :notes,      :maximum => 100, :allow_nil => true
  validates_length_of     :teach_tags_string, :maximum => 10240, :allow_blank => true
  validates_length_of     :learn_tags_string, :maximum => 10240, :allow_blank => true

  before_save :set_status
	after_save  :save_learn_tags, :save_teach_tags

	#	here we make sure all empty? params replaced by nils
	def before_validation
		[:first_name, :last_name, :city, :region, :country, :more_info, :openid, :notes, :email].each do |param|
			self.send("#{param.to_s}=", nil) if !self.send(param.to_s).nil? && self.send(param.to_s).empty?
		end
	end

	def learn_tags_string=(t)
		@learn_tags_string = t if t
	end

	def teach_tags_string=(t)
		@teach_tags_string = t if t
	end

	def learn_tags_string
		join_tags_to_string(self.learn_tags)
	end

	def teach_tags_string
		join_tags_to_string(self.teach_tags)
	end



	private

  def validate_email
    if (!email.blank?)
      unless email =~ /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
        errors.add(:email, 'is invalid')
      end
    end
  end

  def set_status
    if @teach_tags_string and @learn_tags_string and
    @teach_tags_string.empty? and @learn_tags_string.empty?
      self.status = 'disabled' 
    else
      self.status = nil
    end
  end

	def save_learn_tags
		self.learn_taggings.delete_all if @learn_tags_string
		self.learn_tags << split_tags_string(@learn_tags_string).map {|t| Tag.find_or_create_by_string(t)}
	end

	def save_teach_tags
		self.teach_taggings.delete_all if @teach_tags_string
		self.teach_tags << split_tags_string(@teach_tags_string).map {|t| Tag.find_or_create_by_string(t)}
	end


end
