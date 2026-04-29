require "rails_helper"

RSpec.describe "GeneratedContents", type: :request do
  let(:user)     { create(:user) }
  let(:other)    { create(:user) }
  let(:pipeline) { create(:pipeline, user: user) }
  let!(:content) { create(:generated_content, pipeline: pipeline) }

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
  end

  describe "POST /pipelines/:pipeline_id/generated_content/:id/retry" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        post retry_pipeline_generated_content_path(pipeline, content)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "creates a new generated_content with an incremented version" do
        expect {
          post retry_pipeline_generated_content_path(pipeline, content)
        }.to change(GeneratedContent, :count).by(1)

        expect(GeneratedContent.last.version).to eq(content.version + 1)
      end

      it "enqueues a GeneratedContentJob for the new content" do
        expect {
          post retry_pipeline_generated_content_path(pipeline, content)
        }.to have_enqueued_job(GeneratedContentJob)
      end

      it "returns 204 no content" do
        post retry_pipeline_generated_content_path(pipeline, content)
        expect(response).to have_http_status(:no_content)
      end

      it "returns 404 for another user's pipeline" do
        other_pipeline = create(:pipeline, user: other)
        other_content  = create(:generated_content, pipeline: other_pipeline)

        post retry_pipeline_generated_content_path(other_pipeline, other_content)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
