class Message < ActiveRecord::Base

  belongs_to :user
  attr_accessible :body, :recipient_id

  [:body, :recipient_id].each { |attribute| validates_presence_of attribute }
  validates_length_of   :body, :maximum => 5000

  validate_on_create :check_last_message_time, :check_emails

  def recipient_id=(id)
    write_attribute(:recipient_id, id)
    @recipient = User.find_by_id(id)
  end

  def after_create
    UserMailer.deliver_user_message(:from => self.user.email, :to => @recipient.email, :body => self.body) if self.valid?
  end

  private

  def check_last_message_time
    last_message = 
    self.class.find(:first, :conditions => ['user_id = (?)', self.user_id], :order => 'created_at DESC')

    errors.add_to_base(
      "You can't send messages that often, please wait for a while"
    ) if last_message and last_message.created_at > 10.minutes.ago
  end

  def check_emails
    errors.add_to_base(
      "You can't send messages, 
      because you haven't provided your own email in your profile"
    ) and return if self.user.email.blank?

    errors.add_to_base(
      "You can't send messages, 
      because this user haven't provided his email"
    ) if User.find_by_id(self.recipient_id).email.blank?
  end

end
