# class ApiController < ActionController::API を使うとCSRFトークン認証のskipが不要になりそう
# app/api/application_controller.rb でActionController::API継承するとよさそう
class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :token_authenticate, except: [:sign_in]

  def sign_in
    if params[:login_name] == ENV['API_LOGIN_NAME'] && params[:password] == ENV['API_PASSWORD']
      linkage = Linkage.create!
    end
    if linkage.present?
      render json: {token: linkage.token}
    else
      head :no_content
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
    render json: @value
  end

  #------------------------- マスタ更新 -------------------------
  def upsert_items
    Item.upsert_all JSON.parse(params.require(:items))
    head :no_content
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
    render json: @value
  end
  def upsert_mng_reservations
    MngReservation.upsert_all JSON.parse(params.require(:mng_reservations))
    head :no_content
  end
  def destroy_mng_reservations
    MngReservation.where(id: params[:ids]).destroy_all
    head :no_content
  end

  #------------------------- WEB予約更新 -------------------------
  # 予約側予約情報の[id]リスト
  def web_reservation_ids
    @value = {ids: WebReservation.has_not_mng.select(:id).pluck(:id)}
    render json: @value
  end

  def web_reservation
    web_reservation = WebReservation.eager_load(:user).find(params[:id])
    h_web = web_reservation.attributes
    h_web[:user] = {
      id: web_reservation.user.id,
      user_name: web_reservation.user.user_name
    }
    @value = {web_reservation: h_web}
    render json: @value
  end

  def update_web_reservation
    h_web = JSON.parse(params.require(:web_reservation))
    web_reservation = WebReservation.includes(:mng_reservation).find(h_web['id'])
    h_mng = h_web.delete('mng_reservation')
    success = web_reservation.update_mng_linkage(h_web, h_mng)

    render json: {success: success}
  end

  private
    def token_authenticate
      authenticate_or_request_with_http_token do |token, options|
        # Linkageモデルに有効期限のみのscopeをつくる
        # find_by! で見つからないと例外を出せる
        # @linkage = Linkage.available.find_by!(token: token)
        # @linkage.destroyが不要なのであればTransactionも不要になる
        @linkage = Linkage.available.find_by(token: token)
        # 認証失敗時にHTTP Token: Access denied.を返すためbool
        @linkage.present?
      end
    end
end
