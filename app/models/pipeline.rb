class Pipeline < ApplicationRecord
  belongs_to :user
  has_many :generated_contents, dependent: :destroy

  validates :topic, presence: true
  validates :formats, presence: true
end
