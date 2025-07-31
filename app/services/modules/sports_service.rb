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

  def default_schedule_data
    [
      { week: 1, home: 'Cleveland Browns', away: 'Pittsburgh Steelers' },
      { week: 2, home: 'Baltimore Ravens', away: 'Cleveland Browns' },
      { week: 3, home: 'Cincinatti Bengals', away: 'Cleveland Browns' },
      { week: 4, home: 'Pittsburgh Steelers', away: 'Cleveland Browns' }
    ]
  end
end
