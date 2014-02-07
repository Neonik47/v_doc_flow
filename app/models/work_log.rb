class WorkLog
  include Mongoid::Document

  embedded_in :document
  belongs_to :user
  # field :user, type: Moped::BSON::ObjectId
  field :time, type: Time
  field :action, type: Symbol
  field :comment
end
