class PipelinesController < ApplicationController
  before_action :authenticate_user!

  VALID_FORMATS = %w[tweet_thread linkedin_post blog_outline email_newsletter].freeze

  def index
    @pipelines = current_user.pipelines.order(created_at: :desc)
  end

  def show
    @pipeline = current_user.pipelines.includes(:generated_contents).find(params[:id])
  end

  def new
    @pipeline = Pipeline.new
  end

  def create
    formats = Array(params[:pipeline][:formats]).select { |f| VALID_FORMATS.include?(f) }

    if formats.empty?
      @pipeline = Pipeline.new(topic: params[:pipeline][:topic])
      @pipeline.errors.add(:formats, "must have at least one format selected")
      return render :new, status: :unprocessable_entity
    end

    @pipeline = current_user.pipelines.build(topic: params[:pipeline][:topic], formats: formats, tone: params[:pipeline][:tone])

    if @pipeline.save
      formats.each do |format|
        content = @pipeline.generated_contents.create!(format: format, status: "pending", version: 1)
        GeneratedContentJob.perform_later(content.id)
      end

      redirect_to @pipeline
    else
      render :new, status: :unprocessable_entity
    end
  end
end
