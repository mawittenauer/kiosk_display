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
    []
  end

  private

  def fetch_schedule_data(team)
    puts team
    response = self.class.get("/schedule/season/#{@season}.json", {
      query: {
        key: @api_key
      }
    })
    puts response.inspect

    if response.success?
      parse_schedule_response(response.parsed_response, team)
    else
      []
    end
  end

  def parse_schedule_response(data, team)
    games = data['games'].select do |game| 
      game['teams']['away']['name'] == team || game['teams']['home']['name'] == team
    end
    games.map do |game|
      {
        week: game['season']['week'],
        home: game['teams']['home']['name'],
        away: game['teams']['away']['name'],
      }
    end
  end
end
