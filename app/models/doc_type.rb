class DocType
  include Mongoid::Document

  module Defines
    FIELD_TYPES = {
      "string" => "Строка",
      "integer" => "Целое число",
      "float" => "Дробное число",
      "date" => "Дата"
    }

  end

  field :name
  field :doc_fields, type: Array, default: []

  def empty_field
    return {:name => "", :type => ""}
  end
end
