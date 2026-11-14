class ApplicationController < ActionController::Base
  layout -> { current_user ? "contracts" : "application" }
  before_action :require_authentication
  before_action :prevent_caching
  helper_method :current_user

  private

  def current_user
    @current_user ||= login_session&.user
  end

  def login_session
    return @login_session if defined?(@login_session)

    @login_session = Session.includes(:user).find_by(id: session[:login_session_id])
    if @login_session && (@login_session.expires_at <= Time.current || !@login_session.user.active?)
      @login_session.destroy!
      @login_session = nil
      reset_session
    end
    @login_session
  end

  def require_authentication
    redirect_to new_session_path unless current_user
  end

  def prevent_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
