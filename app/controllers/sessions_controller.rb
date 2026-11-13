class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render plain: "Zu viele Anmeldeversuche. Bitte später erneut versuchen.", status: :too_many_requests }

  def new
  end

  def create
    user = User.authenticate_by(email_address: params[:email_address].to_s, password: params[:password].to_s)
    if user&.active?
      reset_session
      session[:login_session_id] = user.sessions.create!(expires_at: 12.hours.from_now).id
      redirect_to plants_path, status: :see_other
    else
      flash.now[:alert] = "Anmeldung nicht möglich. Bitte Zugangsdaten prüfen."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    login_session&.destroy!
    reset_session
    redirect_to new_session_path, status: :see_other
  end
end
