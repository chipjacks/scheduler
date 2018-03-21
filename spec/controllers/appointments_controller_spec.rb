require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    before :each do
      6.times { FactoryBot.create(:appointment, coach: user.coach) }
    end

    it "lists coach appointments" do
      get :index, format: :json
      expect(JSON.parse(response.body).size).to eq 6
    end
  end

  describe "POST #create" do
    it "creates a new appointment" do
      appointment = FactoryBot.build(:appointment, user: user)
      expect {
        post :create, params: { appointment: { time: appointment.time } }, format: :json
      }.to change{ user.appointments.count }.by(1)
    end

    it 'returns an error if no user is signed in' do
      sign_out user
      appointment = FactoryBot.build(:appointment, user: user)
      post :create, params: { appointment: { time: appointment.time } }, format: :json
      expect(response).to have_http_status(401)
      expect(response.body).to include "You need to sign in"
    end

    it "returns an error if slot is already taken" do
      appointment = FactoryBot.create(:appointment, user: user)
      post :create, params: { appointment: { time: appointment.time } }, format: :json
      expect(response).to have_http_status(422)
      expect(response.body).to include "Time has already been taken"
    end

    it "returns an error if appointment outside standard business hours" do
      appointment = FactoryBot.build(:appointment, user: user, time: "2018-03-21 23:00:00 PST")
      post :create, params: { appointment: { time: appointment.time } }, format: :json
      expect(response).to have_http_status(422)
      expect(response.body).to include "Time is outside standard business hours"
    end
  end

  describe "GET #show" do
    it "returns appointment details" do
      appointment = FactoryBot.create(:appointment, user: user)
      get :show, params: { id: appointment.id }, format: :json
      expect(DateTime.parse(JSON.parse(response.body)['time'])).to eq appointment.time
    end
  end

  describe "PUT #update" do
    it "updates appointment details" do
      appointment = FactoryBot.create(:appointment, user: user)
      expect {
        put :update, params: { id: appointment.id,
          appointment: {time: "2018-03-21 10:00:00 PST"}
        }, format: :json
        appointment.reload
      }.to change { appointment.time }
    end
  end

  describe "DELETE #destroy" do
    it "destroys an appointment" do
      appointment = FactoryBot.create(:appointment, user: user)
      expect {
        delete :destroy, params: {id: appointment.id}, format: :json
      }.to change { user.appointments.count }.by (-1)
    end
  end

end
