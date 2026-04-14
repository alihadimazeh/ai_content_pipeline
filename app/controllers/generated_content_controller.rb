# frozen_string_literal: true

class GeneratedContentController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pipeline

  def retry
    old_content = @pipeline.generated_contents.find(params[:id])
    new_content = @pipeline.generated_contents.create(
      format: old_content.format,
      status: "pending",
      version: old_content.version + 1
    )

    if new_content.persisted?
      GeneratedContentJob.perform_later(new_content.id)

      Turbo::StreamsChannel.broadcast_replace_to(
        @pipeline,
        target: ActionView::RecordIdentifier.dom_id(old_content),
        partial: "pipelines/generated_content",
        locals: { generated_content: new_content }
      )

      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def set_pipeline
    @pipeline = current_user.pipelines.find(params[:pipeline_id])
  end
end
