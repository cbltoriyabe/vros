class Channel < ApplicationRecord
  has_many :program, :class_name => "Program"
  validates :c_url, {uniqueness: true}
end
