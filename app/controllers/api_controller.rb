# class ApiController < ActionController::API を使うとCSRFトークン認証のskipが不要になりそう
# app/api/application_controller.rb でActionController::API継承するとよさそう
class ApiController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # CSRFトークン認証対応
  # skip_before_action :verify_authenticity_token
  before_action :token_authenticate, except: [:sign_in]

  def sign_in
    puts "password #{params[:password] }"
    if params[:login_name] == ENV['API_LOGIN_NAME'] && params[:password] == ENV['API_PASSWORD']
      linkage = Linkage.create!
    end
    respond_to do |format|
      if linkage.present?
        format.json { render json: {token: linkage.token} }
      else
        format.json { head :no_content }
      end
    end
  end

  def sign_out
    if @linkage.present?
      @linkage.destroy
      @linkage = nil
    end
  end

  def master_updated_at
    @value = {
      items: Item.with_deleted.maximum(:updated_at),
    }
    respond_to do |format|
      format.json { render json: @value }
    end
  end

  #------------------------- マスタ更新 -------------------------
  def upsert_items
    Item.upsert_all JSON.parse(params.require(:items))
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  #------------------------- MNG予約更新(WEB非連携) -------------------------
  # MNG予約(WEB非連携)の{id: updated_at}リスト
  def mng_reservation_id_updated_at
    date = Date.parse(params[:date])
    if date.present?
      # {id: updated_at}の形にする
      mng_reservations = {}
      MngReservation.belongs_not_web.where('mng_reservations.end_date >= ?', date).select(:id, :updated_at).each do |r|
        mng_reservations[r.id] = r.updated_at
      end
      @value = {mng_reservations: mng_reservations}
    else
      @value = {}
    end
    respond_to do |format|
      format.json { render json: @value }
    end
  end
  def upsert_mng_reservations
    MngReservation.upsert_all JSON.parse(params.require(:mng_reservations))
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  def destroy_mng_reservations
    MngReservation.where(id: params[:ids]).destroy_all
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  #------------------------- WEB予約更新 -------------------------
  # 予約側予約情報の[id]リスト
  def web_reservation_ids
    @value = {ids: WebReservation.has_not_mng.select(:id).pluck(:id)}
    respond_to do |format|
      format.json { render json: @value }
    end
  end

  def web_reservation
    web_reservation = WebReservation.eager_load(:user).find(params[:id])
    h_web = web_reservation.attributes
    h_web[:user] = {
      id: web_reservation.user.id,
      user_name: web_reservation.user.user_name
    }
    @value = {web_reservation: h_web}
    respond_to do |format|
      format.json { render json: @value }
    end
  end

  def update_web_reservation
    h_web = JSON.parse(params.require(:web_reservation))
    web_reservation = WebReservation.includes(:mng_reservation).find(h_web['id'])
    h_mng = h_web.delete('mng_reservation')

    success = false
    WebReservation.transaction do
      web_reservation.attributes = h_web

      if h_web.present?
        # web_reservationモデルにロジックをもたせたい
        # 予約側：webとmngのマスタ、管理側：mngのマスタを扱っているので、予約側は1つのマスタにしたい。理想は予約側と管理側で1つのマスタだけど。

        # reservation専用のコントローラをつくるとスッキリかけそう。

        # 生成済みでもIDが異なるなら削除
        if web_reservation.mng_reservation.present? && (h_mng.blank? || web_reservation.mng_reservation.id.to_s != h_mng['id'].to_s)
          puts "mng_reservation re-created #{web_reservation.mng_reservation.id}"
          web_reservation.mng_reservation.destroy
          web_reservation.mng_reservation = nil
        end

        if web_reservation.mng_reservation.present?
          puts "web_reservation.mng_reservation.present? true #{web_reservation.mng_reservation.id}"
          web_reservation.mng_reservation.attributes = h_mng
          web_reservation.mng_reservation.save!
        elsif h_mng.present?
          puts "web_reservation.mng_reservation.present? false"
          web_reservation.mng_reservation = MngReservation.new(h_mng)
          web_reservation.mng_reservation.save!
        end

      # 予約情報が消えた場合
      elsif web_reservation.mng_reservation.present?
        puts "web_reservation.mng_reservation destroy #{web_reservation.mng_reservation.id}"
        web_reservation.mng_reservation.destroy
        web_reservation.mng_reservation = nil
      end

      success = web_reservation.save
    end
    respond_to do |format|
      format.json { render json: {success: success} }
    end
  end

  private
    def token_authenticate
      authenticate_or_request_with_http_token do |token, options|

        # Linkageモデルに有効期限のみのscopeをつくる
        # find_by! で見つからないと例外を出せる
        # @linkage = Linkage.available.find_by!(token: token)
        # @linkage.destroyが不要なのであればTransactionも不要になる

        Linkage.transaction do
          @linkage = Linkage.find_by(token: token)
          # 60分で無効
          if @linkage.present? && @linkage.created_at < 60.minutes.ago
            @linkage.destroy
            @linkage = nil
          end
        end
        @linkage.present?
      end
    end
end
