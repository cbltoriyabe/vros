class User < ApplicationRecord
  validates :g_id, {uniqueness: true}
end
