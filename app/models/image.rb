class Image
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :doc, :inverse_of => :images

  has_mongoid_attached_file :file, :styles => { :thumb => "100x100>" },
  :url => "/system/:attachment/:id/:style/:basename.:extension",
  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  attr_accessible :file, :file_file_name

  validates_attachment_presence :file
  validates_attachment_size :file, :less_than => 2.megabytes
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/png']
end
