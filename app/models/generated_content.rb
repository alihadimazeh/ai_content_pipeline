class GeneratedContent < ApplicationRecord
  belongs_to :pipeline

  validates :format, presence: true
  validates :status, presence: true
  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
