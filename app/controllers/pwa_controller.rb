class PwaController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :check_onboarding, raise: false
  skip_before_action :verify_authenticity_token, raise: false
  skip_after_action :verify_same_origin_request!, raise: false

  def manifest
    render layout: false
  end

  def service_worker
    render layout: false, content_type: "application/javascript"
  end

  def offline
    render status: :ok
  end
end
