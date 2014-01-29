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
  embeds_many :images, :cascade_callbacks => true
  accepts_nested_attributes_for :images
  attr_accessible :images_attributes

  def Doc::human_type(type)
    Line::Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end

  def human_status
    Defines::STATUSES[status] || "Статус '#{status}' неопределен!"
  end

end
