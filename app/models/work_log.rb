class WorkLog
  include Mongoid::Document

  embedded_in :document
  belongs_to :user
  field :target_id, type: Moped::BSON::ObjectId, default: nil
  field :time, type: Time
  field :action, type: Symbol
  field :comment
end
