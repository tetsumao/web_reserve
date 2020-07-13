class WebReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_web_reservation, only: [:show]

  def index
    @web_reservations = current_user.web_reservations.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def status
    date_from = params[:date_from]
    @date_from = date_from.present? ? Date.parse(date_from) : Date.today
    # 開始日付は必ず今日以降
    @date_from = Date.today if @date_from < Date.today
    @date_to = @date_from + 6
    @items = Item.all
  end

  def new
    @web_reservation = WebReservation.new
  end

  def create
    @web_reservation = current_user.web_reservations.build(web_reservation_params)
    @web_reservation.reservation_date = Date.today

    if @web_reservation.save
      redirect_to web_reservations_url, notice: 'アイテムを予約しました。'
    else
      render :new
    end
  end

  private
    def set_web_reservation
      @web_reservation = WebReservation.find(params[:id])
    end
    def web_reservation_params
      params.require(:web_reservation).permit(:item_id, :number, :start_date, :end_date)
    end
end
