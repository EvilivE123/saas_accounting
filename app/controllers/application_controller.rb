class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
before_action :authenticate_user!
  before_action :set_current_tenant, if: :user_signed_in?

  # 1. Global Exception Handling for API/Ajax Calls
  # Prevents standard ActiveRecord errors from crashing JS clients
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  protected

  # 2. Standardized JSON Success Response Helper
  def render_json_success(message, data = {}, status = :ok)
    render json: { 
      success: true, 
      message: message, 
      data: data 
    }, status: status
  end

  # 3. Standardized JSON Error Response Helper
  def render_json_error(errors, status = :unprocessable_entity)
    render json: { 
      success: false, 
      errors: Array(errors) # Ensures errors are always an array for JS iteration
    }, status: status
  end

  private

  def set_current_tenant
    Current.user = current_user
    Current.organization = current_user.organization
  end

  # Exception Handlers
  def render_not_found(exception)
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false }
      format.json { render_json_error("Record not found", :not_found) }
    end
  end

  def render_unprocessable_entity(exception)
    respond_to do |format|
      format.html { redirect_back fallback_location: authenticated_root_path, alert: exception.message }
      format.json { render_json_error(exception.record.errors.full_messages, :unprocessable_entity) }
    end
  end
end
