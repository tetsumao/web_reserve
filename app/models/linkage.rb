class Linkage < ApplicationRecord
  has_secure_token

  # 60分で無効化
  scope :available, -> {where(arel_table[:created_at].gt(60.minutes.ago))}
end
