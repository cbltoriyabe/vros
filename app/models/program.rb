class Program < ApplicationRecord
  belongs_to :channel,:class_name => "Channel", :foreign_key => 'channel'
  mount_uploader :image, ImageUploader
  validates :p_url, {presence: true, format: /\A#{URI::regexp(%w(http https))}\z/}
  validates :p_title, {presence: true}
  validates :day, {presence: true}
  validates :start_time, {presence: true}
  validates :about, {presence: true}
  validates :genre, {presence: true}
  validates :archives, {presence: true}
  validates :channel, {presence: true}
  validates :meyasu, {presence: true}
  validates :platform, {presence: true}
  validates :user_id, {presence: true}
  validates :update_id, {presence: true}
  validates :member, {presence: true}
  validates :like, {presence: true}
end
