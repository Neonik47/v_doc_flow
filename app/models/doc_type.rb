class DocType
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

  # attr_accessible :doc_fields_arr

  field :name
  field :deleted, type: Boolean, default: false
  field :doc_fields, type: Array, default: []
  has_many :docs

  scope :active, where(:deleted => false).order_by(:name => 1)

  def DocType::empty_field
    return {:name => "", :type => "", :title => "", :validates => {}}
  end

  def DocType::human_type(field = {})
    Defines::FIELD_TYPES[field["type"]] || "Type '#{field["type"]}' undefined!"
  end

end
