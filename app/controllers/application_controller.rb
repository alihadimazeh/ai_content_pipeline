class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_recent_pipelines, if: :user_signed_in?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def set_recent_pipelines
    @recent_pipelines = current_user.pipelines.order(created_at: :desc).limit(10)
  end
end
