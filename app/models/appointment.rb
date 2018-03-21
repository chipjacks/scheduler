class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :coach

  before_validation :round_time, on: :create

  validates :time, uniqueness: {scope: :coach_id}
  validate :time_within_business_hours

  def round_time
    self.time = time.beginning_of_hour
  end

  def time_within_business_hours
    pst = time.in_time_zone("Pacific Time (US & Canada)")
    if pst.hour < 9 || pst.hour > 17 || pst.wday == 0 || pst.wday == 6
      errors.add(:time, "is outside standard business hours")
    end
  end
end
