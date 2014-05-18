class DocType
  include Mongoid::Document

  field :name
  field :deleted, type: Boolean, default: false

  embeds_many :lines
  has_many :docs

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_length_of :name, minimum: 5, maximum: 40

  accepts_nested_attributes_for :lines, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
  scope :active, ->{where(:deleted => false).order_by(:name => 1)}
end
