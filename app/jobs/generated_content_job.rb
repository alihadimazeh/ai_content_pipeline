class GeneratedContentJob < ApplicationJob
  queue_as :default

  def perform(generated_content_id)
    # Do something later
    content = GeneratedContent.find(generated_content_id)

    result = LlmService.new(format: content.format, topic: content.pipeline.topic).call

    content.update!(body: result, status: "complete")
    broadcast(content)
  rescue StandardError => e
    content&.update!(status: "failed")
    broadcast(content) if content
    raise e
  end

  private

  def broadcast(content)
    Turbo::StreamsChannel.broadcast_replace_to(
      content.pipeline,
      target: ActionView::RecordIdentifier.dom_id(content),
      partial: "pipelines/generated_content",
      locals: { generated_content: content }
    )
  end
end
