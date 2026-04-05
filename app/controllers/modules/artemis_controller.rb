class Modules::ArtemisController < ApplicationController
  def index
    render json: mission_data
  end

  private

  def artemis_service
    @artemis_service ||= Modules::ArtemisService.new
  end

  def mission_data
    artemis_service.mission_data
  end
end
