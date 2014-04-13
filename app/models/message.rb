class Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  after_create :build_notifications

  field :body
  # field :user_id, type: BSON::ObjectId, default: nil
  embedded_in :chat_room
  has_many :message_notifications
  belongs_to :user

  def system_message?
    return user_id.nil?
  end

  def build_notifications
    ( chat_room.member_ids - [user_id] ).each do |user_id|
      self.message_notifications.create(user_id: user_id, chat_room_id: chat_room.id)
    end
  end

  protected

end
