class Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :body
  field :user_id, type: BSON::ObjectId, default: nil
  embedded_in :chat_room
  has_many :message_notifications

  def system_message?
    return user_id.nil?
  end

  protected

end
