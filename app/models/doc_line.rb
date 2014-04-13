class DocLine
  include Mongoid::Document

  module Defines
    FIELD_TYPES = {
      "string" => "Строка",
      "integer" => "Целое число",
      "float" => "Дробное число",
      "date" => "Дата",
      "boolean" => "Логический"
    }
  end

  field :name
  field :value
  field :type
  field :title, default: ""

  embedded_in :doc

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  #в виду вложенности в документ, уникальность поля будет только в рамках документа (по идее)
  validates_length_of :name, maximum: 20

  validates_presence_of :type

  validate :correct_value

  def correct_value
    return if self.new_record?
    validates_presence_of :value, message: "'#{name}' не может быть пустым"
    case self.type
    when "string"
      # варианты
    when "integer"
      validates_numericality_of :value, only_integer: true,
        message: "'#{name}' может быть только целым числом"
    when "float"
      validates_numericality_of :value,
        message: "'#{name}' может быть только числом"
    when "date"
      validates_format_of :value, with: /(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.(19|20)\d\d/,
        message: "'#{name}' может быть только в формате дд.мм.гггг"
    when "boolean"
      validates_inclusion_of :value, { in: %w(0 1),
        message: "'#{name}' может быть только '0' или '1'" }
    end
  end

  def human_type
    Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end
end
