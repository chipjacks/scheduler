class AppointmentsController < ApplicationController
  include ExceptionHandler
  include Response

  before_action :authenticate_user!
  before_action :authenticate, if: -> { request.format == :json }
  before_action :set_appointment, only: [:show, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    json_response(current_user.coach.appointments)
  end

  def create
    attrs = appointment_params.merge(coach_id: current_user.coach_id, user_id: current_user.id)
    appt = current_user.appointments.create!(attrs)
    json_response(appt, :created)
  end

  def show
    json_response(@appointment)
  end

  def update
    @appointment.update(appointment_params)
    head :no_content
  end

  def destroy
    @appointment.destroy
    head :no_content
  end

  private

  def appointment_params
    params.require(:appointment).permit(:time)
  end

  def coach_params
    params.permit(:coach_id)
  end

  def authenticate
    unless current_user
      raise ExceptionHandler::AuthenticationError
    end
  end

  def set_appointment
    @appointment = current_user.appointments.find_by!(id: params[:id])
  end
end
