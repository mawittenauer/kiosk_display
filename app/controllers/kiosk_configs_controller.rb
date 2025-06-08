class KioskConfigsController < ApplicationController
  def index
    render json: kiosk_config
  end
  
  def create
    if kiosk_config.update(config_params)
      render json: kiosk_config
    else
      render json: { errors: kiosk_config.errors }, status: 422
    end
  end
  
  def update
    if kiosk_config.update(config_params)
      render json: kiosk_config
    else
      render json: { errors: kiosk_config.errors }, status: 422
    end
  end
  
  private
  
  def config_params
    params.require(:kiosk_config).permit(:zipcode, :refresh_interval, modules_enabled: [])
  end
end
