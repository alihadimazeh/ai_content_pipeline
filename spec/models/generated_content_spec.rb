require "rails_helper"

RSpec.describe GeneratedContent, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:pipeline) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:format) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_numericality_of(:version).only_integer.is_greater_than(0) }

    it "is valid with all required attributes" do
      content = build(:generated_content)
      expect(content).to be_valid
    end
  end
end
