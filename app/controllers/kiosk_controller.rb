class KioskController < ApplicationController
  def index
    @modules = load_enabled_modules
  end
  
  private
  
  def load_enabled_modules
    modules = []
    
    if kiosk_config.modules_enabled.include?('weather')
      modules << {
        name: 'weather',
        partial: 'modules/weather/display',
        data: { 
          current_weather: Modules::WeatherService.new(kiosk_config.zipcode).current_weather,
          forecast: Modules::WeatherService.new(kiosk_config.zipcode).extended_forecast }
        }
    end

    if kiosk_config.modules_enabled.include?('network')
      modules << {
        name: 'network',
        partial: 'modules/network/display',
        data: Modules::NetworkService.new.devices
      }
    end
    
    modules
  end
end
