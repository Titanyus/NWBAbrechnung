class HealthController < ApplicationController
  skip_before_action :require_authentication

  def show
    ActiveRecord::Base.connection.select_value("SELECT 1")
    head :ok
  end
end
