class DocType
  include Mongoid::Document

  field :name
  field :deleted, type: Boolean, default: false

  has_many :lines, :dependent => :destroy
  accepts_nested_attributes_for :lines, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true

  has_many :docs

  scope :active, where(:deleted => false).order_by(:name => 1)

  def DocType::empty_field
    return {:name => "", :type => "", :title => "", :validates => {}}
  end

  def DocType::human_type(field = {})
    Defines::FIELD_TYPES[field["type"]] || "Type '#{field["type"]}' undefined!"
  end

end
