class Image
  include Mongoid::Document
  include Mongoid::Paperclip

  # belongs_to :doc
  embedded_in :listing, :inverse_of => :images

  attr_accessible :file
  has_mongoid_attached_file :file, :styles => { :thumb => "100x100>" },
  :url => "/system/:attachment/:id/:style/:basename.:extension",
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  # embedded_in :doc, :inverse_of => :images
  # validates_attachment_presence :file
  # validates_attachment_size :file, :less_than => 2.megabytes
  # validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/png']

end
