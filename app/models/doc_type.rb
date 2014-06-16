class DocType
  include Mongoid::Document

  PrintSettingsData =
    {
      head: {
        positions: {right: "Справа", centered: "По центру", centered_in_width: "По всей ширине", left: "Слева"},
        cases: {original: "Оригинальный", up: "ВЕРХНИЙ", down: "нижний"}
      },
      title: {
        cases: {original: "Оригинальный", up: "ВЕРХНИЙ"}
      },
      body: {
        cases: {original: "Оригинальный", up: "ВЕРХНИЙ"}
      },
      footer: {

      }
    }

  field :name
  field :is_deleted, type: Boolean, default: false
  field :print_settings, type: Hash, default: {}

  embeds_many :lines
  has_many :docs

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_length_of :name, minimum: 5, maximum: 40

  accepts_nested_attributes_for :lines, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
  scope :active, ->{where(:is_deleted => false).order_by(:name => 1)}

  def delete!
    self.is_deleted = true
    self.save
  end
end
