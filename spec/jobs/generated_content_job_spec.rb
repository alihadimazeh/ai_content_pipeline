require "rails_helper"

RSpec.describe GeneratedContentJob, type: :job do
  let(:pipeline) { create(:pipeline) }
  let(:content)  { create(:generated_content, pipeline: pipeline) }

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
  end

  describe "#perform" do
    context "when LlmService succeeds" do
      before do
        allow_any_instance_of(LlmService).to receive(:call).and_return("Generated text")
      end

      it "updates the content body with the returned text" do
        described_class.new.perform(content.id)
        expect(content.reload.body).to eq("Generated text")
      end

      it "sets status to complete" do
        described_class.new.perform(content.id)
        expect(content.reload.status).to eq("complete")
      end

      it "broadcasts the updated content" do
        described_class.new.perform(content.id)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to)
      end
    end

    context "when LlmService raises" do
      before do
        allow_any_instance_of(LlmService).to receive(:call).and_raise(StandardError, "API down")
      end

      it "sets status to failed" do
        described_class.new.perform(content.id) rescue nil
        expect(content.reload.status).to eq("failed")
      end

      it "re-raises the error" do
        expect { described_class.new.perform(content.id) }.to raise_error(StandardError, "API down")
      end

      it "broadcasts the failed content" do
        described_class.new.perform(content.id) rescue nil
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to)
      end
    end
  end
end
