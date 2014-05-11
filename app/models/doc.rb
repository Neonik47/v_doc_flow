class Doc
  include Mongoid::Document

#   Имя,
# Вх номер
# Исх номер,
# Отдел отправитель,
# ФИО и должность отправителя,
# ФИО и должность кому предназначается документ

  module Defines
  end

  field :name
  field :in_num
  field :out_num
  field :department
  field :status, type: String, default: "draft"
  field :is_deleted, type: Boolean, default: false
  field :is_public, type: Boolean, default: false

  field :chat_room_id, type: BSON::ObjectId, default: nil

  field :sender_id, type: BSON::ObjectId, default: nil
  field :executor_id, type: BSON::ObjectId, default: nil
  field :responsibles, type: Array, default: [] #ответственные

  belongs_to :doc_type
  belongs_to :user
  embeds_many :work_logs
  embeds_many :images, cascade_callbacks: true
  embeds_many :doc_lines, cascade_callbacks: true

  accepts_nested_attributes_for :doc_lines, :allow_destroy => false
  accepts_nested_attributes_for :images
  # attr_accessible :images_attributes, :doc_lines_attributes, :name,
  # :in_num, :out_num, :department, :doc_type_id

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_length_of :name, minimum: 5, maximum: 40

  validates_presence_of :in_num
  validates_uniqueness_of :in_num, case_sensitive: false
  validates_length_of :in_num, minimum: 3, maximum: 16

  validates_presence_of :out_num
  validates_uniqueness_of :out_num, case_sensitive: false
  validates_length_of :out_num, minimum: 3, maximum: 16

  validates_presence_of :department
  validates_length_of :department, minimum: 5, maximum: 16

  validates_presence_of :status

  state_machine :status, initial: :draft do

    state :draft #Черновик
    state :on_review #На рассмотрении
    state :rejected #Отклонен
    state :on_revision #На доработке
    state :accepted #Принят
    state :on_execution #На исполнении
    state :confirmation_of_execution #Подтверждение исполнения
    state :executed #Исполнено

    # Редактировать
    event :edit do
      transition :draft => :draft
      transition :on_revision => :on_revision
    end
    # Сменить ответственного
    event :change_responsible do
      transition :draft => :draft # if owner
      transition :on_revision => :on_revision # if owner
      transition :accepted => :accepted # if responsible
    end
    # Отправить на рассмотрение
    event :to_review do
      transition :accepted => :on_review , :if => lambda {|doc| doc.has_executor? && doc.current_executor.try(:role) != "engineer"}
      transition :draft => :on_review, :if => lambda {|doc| doc.has_executor?}
      transition :on_revision => :on_review, :if => lambda {|doc| doc.has_executor?}
    end
    # Отклонить
    event :reject do
      transition :on_review => :rejected
    end
    # Забрать на доработку
    event :to_revision do
      transition :rejected => :on_revision
      transition :on_review => :on_revision
    end
    # Принять
    event :accept do
      transition :on_review => :accepted
    end
    # Отправить на исполнение
    event :to_execution do
      transition :accepted => :on_execution, :if => lambda {|doc| doc.current_executor.try(:role) == "engineer"}
      transition :confirmation_of_execution => :on_execution
    end
    # Отправить на подтверждение исполнения
    event :to_confirmation_of_execution do
      transition :on_execution => :confirmation_of_execution
    end
    # Подтвердить исполнение
    event :to_executed do
      transition :confirmation_of_execution => :executed
    end

  end


  def current_sender
    User.where(_id: sender_id).first
  end

  def current_executor
    User.where(_id: executor_id).first
  end

  def current_responsible_id
    return case self.status
    when "draft", "rejected", "on_revision", "accepted", "confirmation_of_execution", "executed"
      sender_id
    when "on_review", "on_execution"
      executor_id
    end
  end

  def can?(event, user)
    w_id = case event
    when :edit, :change_responsible, :to_review, :to_revision, :to_execution, :to_executed
      sender_id
    when :reject, :accept, :to_confirmation_of_execution
      executor_id
    end
    return ( w_id == user.id || user.admin? ) && self.send("can_#{event}?")
  end

  def chat_room
    return nil unless chat_room_id
    return ChatRoom.find(chat_room_id)
  end

  def level
    return 1 if responsibles.empty?
    responsibles.size
  end

  def users_by_doc_stage
    raise if current_sender.blank?
    role = case current_sender.role
    when "secretary"
      "dep_head"
    when "dep_head"
      "deputy_head"
    when "deputy_head"
      "group_head"
    when "group_head"
      "engineer"
    else
      "admin"
    end
    return User.where(role: role).enabled
  end

  # def current_responsible
  #   res = case self.status
  #   when "draft","rejected","on_revision","confirmation_of_execution"
  #     self.sender_id
  #   when "on_review", "on_execution"
  #     self.executor_id
  #   else
  #     raise "Oops with #{self.status}"
  #   end
  #   return User.find(res)
  # end

  def has_executor?
    !executor_id.nil?
  end
end
