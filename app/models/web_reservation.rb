# ※新規生成のみで編集はしない
class WebReservation < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_one :mng_reservation
  # 削除時は0にする
  validates :number, numericality: {greater_than_or_equal_to: 0}

  include StartEndDateHolder

  validate :validate_start_date
  validate :validate_item_stock

  before_save do
    self.reservation_name = "#{self.item.item_name} x #{self.number}：#{self.start_end_date_to_s}"
    self.reservation_date = Date.today if self.reservation_date.nil?
  end

  scope :has_not_mng, -> {left_joins(:mng_reservation).where('mng_reservations.id IS NULL')}

  private
    def validate_start_date
      errors.add(:start_date, 'は本日以降を選択してください') if start_date < Date.today
    end
    def validate_item_stock
      if number > 0
        map = ReservedMap.new(item, start_date, end_date)
        errors.add(:item_id, 'は予約一杯の日付があります') unless map.permit_all?(number)
      end
    end
end
