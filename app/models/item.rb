class Item < ApplicationRecord
  acts_as_paranoid
  default_scope {order(:dspo)}
  
  has_many :web_reservations
  has_many :mng_reservations
end
