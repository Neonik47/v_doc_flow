class DocType
  include Mongoid::Document

  field :name
  field :deleted, type: Boolean, default: false

  embeds_many :lines
  has_many :docs

  accepts_nested_attributes_for :lines, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
  scope :active, ->{where(:deleted => false).order_by(:name => 1)}
end
