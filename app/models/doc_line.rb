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

  field :name, default: ""
  field :value
  field :type, default: ""
  field :title, default: ""
  field :validates, type: Hash, default: {}

  embedded_in :doc

  def human_type
    Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end
end
