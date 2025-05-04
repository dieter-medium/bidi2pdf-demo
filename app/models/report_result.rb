class ReportResult < ApplicationRecord
  has_one_attached :pdf
  validates :report_id, presence: true, uniqueness: true
end
