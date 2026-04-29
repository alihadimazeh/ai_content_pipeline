require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:pipelines).dependent(:destroy) }
  end

  describe "dependent destroy" do
    it "destroys associated pipelines when the user is destroyed" do
      user = create(:user)
      create_list(:pipeline, 2, user: user)

      expect { user.destroy }.to change(Pipeline, :count).by(-2)
    end
  end

  describe "validations" do
    it "is invalid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "taken@example.com")
      duplicate = build(:user, email: "taken@example.com")
      expect(duplicate).not_to be_valid
    end

    it "is invalid without a password" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end
end
