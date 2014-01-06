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

  field :name
  field :type
  field :title

  belongs_to :doc_type

  def human_type
    Defines::FIELD_TYPES[type] || "Type '#{type}' undefined!"
  end
end
