class Modules::SportsService
  include HTTParty

  base_uri 'https://api.sportsblaze.com/nfl/v1'

  def initialize(season)
    @season = season
    @api_key = ENV['SPORTS_API_KEY'] || 'your_api_key_here'
  end

  def schedule(team)
    Rails.cache.fetch("sports_schedule_#{@season}_#{team}", expires_in: 10.minutes) do
      fetch_schedule_data(team)
    end
  rescue => e
    Rails.logger.error "Sports API Error: #{e.message}"
    default_schedule_data
  end

  private

  def fetch_schedule_data(team)
    response = self.class.get("/schedule/season/#{@season}.json", {
      query: {
        key: @api_key
      }
    })

    if response.success?
      parse_schedule_response(response.parsed_response, team)
    else
      default_schedule_data
    end
  end

  def sparse_schedule_response(data, team)
    games = data['games'].select do |game| 
      game['teams']['away'] == team || game['teams']['home'] == team
    end
    games.map do |game|
      {
        week: game['week'],
        home: game['teams']['home'],
        away: game['teams']['away']
      }
    end
  end
end
