require "rails_helper"

RSpec.describe Pipeline, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:generated_contents).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:topic) }

    it "is invalid when formats is empty" do
      pipeline = build(:pipeline, formats: [])
      expect(pipeline).not_to be_valid
      expect(pipeline.errors[:formats]).to include("must have at least one format selected")
    end

    it "is invalid when formats is nil" do
      pipeline = build(:pipeline, formats: nil)
      expect(pipeline).not_to be_valid
    end

    it "is valid with a topic and at least one format" do
      pipeline = build(:pipeline)
      expect(pipeline).to be_valid
    end
  end

  describe "dependent destroy" do
    it "destroys associated generated_contents when the pipeline is destroyed" do
      pipeline = create(:pipeline)
      create_list(:generated_content, 2, pipeline: pipeline)

      expect { pipeline.destroy }.to change(GeneratedContent, :count).by(-2)
    end
  end
end
