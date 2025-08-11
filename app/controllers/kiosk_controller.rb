class KioskController < ApplicationController
  def index
    @modules = load_enabled_modules
  end
  
  private
  
  def load_enabled_modules
    modules = []

    enabled_modules = if params[:modules].present?
      params[:modules].split(',').map(&:strip)
    else
      kiosk_config.modules_enabled
    end
    
    if enabled_modules.include?('weather')
      modules << {
        name: 'weather',
        partial: 'modules/weather/display',
        data: { 
          current_weather: Modules::WeatherService.new(kiosk_config.zipcode).current_weather,
          forecast: Modules::WeatherService.new(kiosk_config.zipcode).extended_forecast }
        }
    end

    if enabled_modules.include?('network')
      modules << {
        name: 'network',
        partial: 'modules/network/display',
        data: Modules::NetworkService.new.devices
      }
    end

    if enabled_modules.include?('flights')
      modules << {
        name: 'flights',
        partial: 'modules/flights/display',
        data: {}
      }
    end

    if enabled_modules.include?('news')
      modules << {
        name: 'news',
        partial: 'modules/news/display',
        data: Modules::NewsService.new.top_news
      }
    end

    if enabled_modules.include?('sports')
      team_name = params[:team] || 'Cleveland Browns'
      modules << {
        name: 'sports',
        partial: 'modules/sports/display',
        data: Modules::SportsService.new(params[:year] || '2025').schedule(team_name)
      }

      modules << {
        name: 'buckeyes',
        partial: 'modules/sports/display',
        data: Modules::SportsService.new(params[:year] || '2025').buckeyes_schedule
      }
    end

    if enabled_modules.include?('finance')
      modules << {
        name: 'finance',
        partial: 'modules/finance/display',
        data: Modules::FinanceService.new.stock_prices(params[:symbols] || ['AAPL', 'GOOGL', 'MSFT'])
      }
    end

    if enabled_modules.include?('notion')
      modules << {
        name: 'notion',
        partial: 'modules/notion/display',
        data: Modules::NotionService.new.pages
      }
    end
    
    modules
  end
end
