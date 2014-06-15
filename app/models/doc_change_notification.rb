class DocChangeNotification
  include Mongoid::Document

  belongs_to :user
  belongs_to :doc

end