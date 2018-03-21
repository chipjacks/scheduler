class CoachesController < ApplicationController
  include ExceptionHandler
  include Response

  def index
    json_response(Coach.all)
  end
end
