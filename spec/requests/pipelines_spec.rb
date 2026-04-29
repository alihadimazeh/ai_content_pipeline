require "rails_helper"

RSpec.describe "Pipelines", type: :request do
  let(:user)  { create(:user) }
  let(:other) { create(:user) }

  describe "GET /pipelines" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get pipelines_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200" do
        get pipelines_path
        expect(response).to have_http_status(:ok)
      end

      it "only shows the current user's pipelines" do
        own     = create(:pipeline, user: user,  topic: "My own pipeline topic")
        foreign = create(:pipeline, user: other, topic: "A foreign pipeline topic")

        get pipelines_path

        expect(response.body).to include(own.topic)
        expect(response.body).not_to include(foreign.topic)
      end
    end
  end

  describe "GET /pipelines/new" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get new_pipeline_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200" do
        get new_pipeline_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /pipelines/:id" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        pipeline = create(:pipeline, user: user)
        get pipeline_path(pipeline)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200 for own pipeline" do
        pipeline = create(:pipeline, user: user)
        get pipeline_path(pipeline)
        expect(response).to have_http_status(:ok)
      end

      it "returns 404 for another user's pipeline" do
        pipeline = create(:pipeline, user: other)
        get pipeline_path(pipeline)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /pipelines" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        post pipelines_path, params: { pipeline: { topic: "test", formats: ["tweet_thread"], tone: "professional" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      context "with valid params" do
        let(:valid_params) do
          { pipeline: { topic: "Why small teams ship faster", formats: ["tweet_thread", "linkedin_post"], tone: "professional" } }
        end

        it "creates a pipeline" do
          expect { post pipelines_path, params: valid_params }.to change(Pipeline, :count).by(1)
        end

        it "creates one generated_content per format" do
          expect { post pipelines_path, params: valid_params }.to change(GeneratedContent, :count).by(2)
        end

        it "enqueues a GeneratedContentJob per format" do
          expect { post pipelines_path, params: valid_params }.to have_enqueued_job(GeneratedContentJob).exactly(2).times
        end

        it "redirects to the new pipeline" do
          post pipelines_path, params: valid_params
          expect(response).to redirect_to(pipeline_path(Pipeline.last))
        end
      end

      context "with no formats selected" do
        it "returns 422 and does not create a pipeline" do
          expect {
            post pipelines_path, params: { pipeline: { topic: "test", formats: [], tone: "professional" } }
          }.not_to change(Pipeline, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with a blank topic" do
        it "returns 422 and does not create a pipeline" do
          expect {
            post pipelines_path, params: { pipeline: { topic: "", formats: ["tweet_thread"], tone: "professional" } }
          }.not_to change(Pipeline, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with invalid format values" do
        it "filters them out and returns 422" do
          expect {
            post pipelines_path, params: { pipeline: { topic: "test", formats: ["not_a_format"], tone: "professional" } }
          }.not_to change(Pipeline, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
