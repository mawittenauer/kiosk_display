class Modules::NetworkController < ApplicationController
  def index
    render json: network_service.devices
  end

  def devices
    render json: network_service.devices
  end

  private

  def network_service
    @network_service ||= Modules::NetworkService.new
  end
end
