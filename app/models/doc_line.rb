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
  field :validates, type: Hash, default: {}

  embedded_in :doc

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  #в виду вложенности в документ, уникальность поля будет только в рамках документа (по идее)
  validates_length_of :name, maximum: 20

  validates_presence_of :type

  def human_type
    Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end
end
