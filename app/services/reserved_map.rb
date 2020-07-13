class ReservedMap
  # {Date: Integer(アイテム数)}
  attr_reader :map

  def initialize(item, start_date, end_date)
    @item = item
    @map = {}
    end_date = start_date if end_date.nil?
    if start_date.is_a?(Date) && end_date.is_a?(Date) && start_date <= end_date
      (start_date..end_date).each {|date| @map[date] = 0}
      MngReservation.where(item: @item).between(start_date, end_date).each do |mng_reservation|
        mng_reservation.date_range(start_date, end_date).each do |date|
          @map[date] += mng_reservation.number
        end
      end
      # MNG予約と紐づかないもののみ
      WebReservation.has_not_mng.where(item: @item).between(start_date, end_date).each do |web_reservation|
        web_reservation.date_range(start_date, end_date).each do |date|
          @map[date] += web_reservation.number
        end
      end
    end
  end

  def permit_all?(num)
    if @map.present?
      @map.each do |date, reserved|
        return false if (@item.stock - reserved) < num
      end
      true
    else
      false
    end
  end

  def reserved(date)
    @map[date].to_i
  end
end