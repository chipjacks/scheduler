require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe '#create' do
    it 'validates time slot uniqueness' do
      appt = FactoryBot.create(:appointment, user: user)
      appt2 = FactoryBot.build(:appointment, user: user, time: appt.time)
      appt3 = FactoryBot.build(:appointment, user: user, time: appt.time + 10.minutes)
      expect(appt2.valid?).to be_falsy
      expect(appt3.valid?).to be_falsy
    end
  end

end
