class Modules::WeatherService
  include HTTParty
  
  base_uri 'http://api.openweathermap.org/data/2.5'
  
  def initialize(zipcode)
    @zipcode = zipcode
    @api_key = ENV['OPENWEATHER_API_KEY'] || 'your_api_key_here'
  end
  
  def current_weather
    Rails.cache.fetch("weather_#{@zipcode}", expires_in: 10.minutes) do
      fetch_weather_data
    end
  rescue => e
    Rails.logger.error "Weather API Error: #{e.message}"
    default_weather_data
  end

  def extended_forecast
    Rails.cache.fetch("weather_forecast_#{@zipcode}", expires_in: 10.minutes) do
      fetch_extended_weather_data
    end
  rescue => e
    Rails.logger.error "Weather Forecast API Error: #{e.message}"
    default_extended_weather_data
  end
  
  private
  
  def fetch_weather_data
    response = self.class.get("/weather", {
      query: {
        zip: "#{@zipcode},US",
        appid: @api_key,
        units: 'imperial'
      }
    })
    
    if response.success?
      parse_weather_response(response.parsed_response)
    else
      default_weather_data
    end
  end

  def fetch_extended_weather_data      
    response = self.class.get("/forecast", {
      query: {
        zip: "#{@zipcode},US",
        appid: @api_key,
        units: 'imperial',
        exclude: 'hourly,minutely,alerts'
      }
    })

    if response.success?
      parse_extended_weather_response(response.parsed_response)
    else
      default_extended_weather_data
    end
  rescue => e
    Rails.logger.error "Weather Forecast API Error: #{e.message}"
    default_extended_weather_data
  end

  def parse_extended_weather_response(data)
    # Group by date, pick one forecast per day (e.g., noon)
    forecasts = data['list'].group_by { |entry| entry['dt_txt'][0,10] }
    forecasts.map do |date, entries|
      max_entry = entries.max_by { |e| e['main']['temp_max'] }
      {
        date: date,
        timezone: "US/New_York",
        temperature: max_entry['main']['temp_max'].round,
        description: max_entry['weather'].first['description'].titleize,
        icon: max_entry['weather'].first['icon']
      }
    end
  end

  def default_extended_weather_data
    []
  end
  
  def parse_weather_response(data)
    {
      temperature: data['main']['temp'].round,
      feels_like: data['main']['feels_like'].round,
      humidity: data['main']['humidity'],
      description: data['weather'].first['description'].titleize,
      icon: data['weather'].first['icon'],
      city: data['name'],
      last_updated: Time.current.strftime('%I:%M %p')
    }
  end
  
  def default_weather_data
    {
      temperature: '--',
      feels_like: '--',
      humidity: '--',
      description: 'Weather data unavailable',
      icon: '01d',
      city: 'Unknown',
      last_updated: Time.current.strftime('%I:%M %p')
    }
  end
end
