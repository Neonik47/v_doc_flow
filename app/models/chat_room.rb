class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name
  field :doc_id, type: BSON::ObjectId, default: nil
  field :member_ids, type: Array, default: []
  belongs_to :user
  has_many :message_notifications
  embeds_many :messages

  validates_presence_of :name

  attr_reader :member_tokens

  def members
    member_ids.map{|id| User.find(id)}
  end

  def member_tokens=(ids)
    self.member_ids = ids.split(",")
  end

  def message_notifications_by_user(user)
    return message_notifications.select{|n| n.user == user}
  end

  def build_system_message(action, user, diff_users = [])
    message = case action
    when :create_room
      "Пользователь <strong>#{user.name}</strong> создал чат."
    when :rename_room
      "Пользователь <strong>#{user.name}</strong> изменил название чата.
      Новое название чата: <strong>#{name}</strong>"
    when :leave_room
      "Пользователь <strong>#{user.name}</strong> покинул чат."
    when :added_users
      "Пользователь <strong>#{user.name}</strong> добавил следующих пользователей в чат (#{diff_users.size}):\n"+
      diff_users.map{|u| u.name}.join("\n")
    when :deleted_users
      "Пользователь <strong>#{user.name}</strong> исключил следующих пользователей из чата (#{diff_users.size}):\n"+
      diff_users.map{|u| u.name}.join("\n")
    end
    s_m = messages.build(body: message)
    s_m.save
  end
end
