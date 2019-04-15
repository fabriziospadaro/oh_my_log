class Doo < ApplicationRecord
  if OHMYLOG_ORM == :mongoid
    include Mongoid::Document
    field :name, type: String
    field :value, type: Integer
    include ::Mongoid::Timestamps
  end
end