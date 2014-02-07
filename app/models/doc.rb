class Doc
  include Mongoid::Document

#   Имя,
# Вх номер
# Исх номер,
# Отдел отправитель,
# ФИО и должность отправителя,
# ФИО и должность кому предназначается документ

  module Defines
    STATUSES = {
      "draft" => "Черновик",
      "revision" => "В доработке",
      "secretariat" => "Рассмотрение секретариата",
      "dep_head" => "Рассмотрение начальника отдела",
      "deputy_head" => "Рассмотрение зам. начальника отдела"
    } #заимствуется из списка ролей

  end

  field :name
  field :in_num
  field :out_num
  field :department
  field :status, type: String, default: "draft"
  field :deleted, type: Boolean, default: false
  field :lines, type: Array, default:[]
  # field :responsible #ответственный
  belongs_to :doc_type
  belongs_to :user
  embeds_many :work_logs
  embeds_many :images, :cascade_callbacks => true
  accepts_nested_attributes_for :images
  attr_accessible :images_attributes


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
      transition :accepted => :on_review # if responsible
    end
    # Отправить на рассмотрение
    event :to_review do
      transition :draft => :on_review
      transition :on_revision => :on_review
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
      transition :accepted => :on_execution
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

    #doc.state_paths.events # => [:park, :ignite, :shift_up, :idle, :crash, :repair, :shift_down]

  end

  def can?(event)
    self.send("can_#{event}?")
  end

  def Doc::human_type(type)
    Line::Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end

  def human_status
    Defines::STATUSES[status] || "Статус '#{status}' неопределен!"
  end

end
