require 'rails_helper'

RSpec.describe CoachesController, type: :controller do

  describe "GET #index" do
    before :each do
      5.times { FactoryBot.create(:coach) }
    end

    it "lists all coaches" do
      get :index, format: :json
      expect(JSON.parse(response.body).size).to eq 5
    end
  end

end
