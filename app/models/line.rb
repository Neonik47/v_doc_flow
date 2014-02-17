class Line
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
  field :type, default: ""
  field :title, default: ""
  field :validates, type: Hash, default: {}

  embedded_in :doc_type
  # belongs_to :doc_type

  def human_type
    Defines::FIELD_TYPES[type] || "Тип '#{type}' неопределен!"
  end
end
