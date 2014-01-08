class Doc
  include Mongoid::Document

#   Имя,
# Вх номер
# Исх номер,
# Отдел отправитель,
# ФИО и должность отправителя,
# ФИО и должность кому предназначается документ

  module Defines

  end

  field :name
  field :in_num
  field :out_num
  field :department
  field :deleted, type: Boolean, default: false
  field :lines, type: Hash, default:{}
  belongs_to :doc_type
  belongs_to :user


end
