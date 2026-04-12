class Pipeline < ApplicationRecord
  belongs_to :user
  has_many :generated_contents, dependent: :destroy

  validates :topic, presence: true
  validate :formats_must_not_be_empty

  private

  def formats_must_not_be_empty
    errors.add(:formats, "must have at least one format selected") if formats.blank?
  end
end
