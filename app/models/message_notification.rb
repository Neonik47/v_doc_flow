class MessageNotification
  include Mongoid::Document

  belongs_to :message
  belongs_to :chat_room
  belongs_to :user

end
