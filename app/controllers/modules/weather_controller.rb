class Modules::WeatherController < ApplicationController
  def index
    render json: { 
      current_weather: weather_service.current_weather,
      forecast: weather_service.extended_forecast
    }
  end
  
  def current
    render json: weather_service.current_weather
  end
  
  private
  
  def weather_service
    @weather_service ||= Modules::WeatherService.new(params[:zipcode] || kiosk_config.zipcode)
  end
end
