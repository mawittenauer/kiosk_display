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
        data: Modules::WeatherService.new(kiosk_config.zipcode).current_weather
      }
    end
    
    modules
  end
end
