class MngReservation < ApplicationRecord
  belongs_to :item
  belongs_to :web_reservation, optional: true
  validates :number, numericality: {greater_than: 0}

  include StartEndDateHolder

  scope :belongs_not_web, -> {left_joins(:web_reservation).where('web_reservations.id IS NULL')}
end
