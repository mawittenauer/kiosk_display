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

  def buckeyes_schedule
    { 
      team: "Ohio State Buckeyes",
      games:
      [
        { week: 1,  home: 'Ohio State Buckeyes', away: 'Texas Longhorns',          date: '2025-08-30T00:00:00Z' },  # Estimated night game
        { week: 2,  home: 'Ohio State Buckeyes', away: 'Grambling State Tigers',   date: '2025-09-06T16:00:00Z' },  # Estimated early afternoon
        { week: 3,  home: 'Ohio State Buckeyes', away: 'Ohio Bobcats',             date: '2025-09-13T16:00:00Z' },  # Estimated early afternoon
        { week: 4,  home: 'Bye',                  away: 'Bye',                      date: '2025-09-20' },
        { week: 5,  home: 'Washington Huskies',   away: 'Ohio State Buckeyes',     date: '2025-09-27T23:00:00Z' },  # Estimated 7 PM PDT = 11 PM UTC
        { week: 6,  home: 'Ohio State Buckeyes',  away: 'Minnesota Golden Gophers',date: '2025-10-04T16:00:00Z' },
        { week: 7,  home: 'Illinois Fighting Illini', away: 'Ohio State Buckeyes', date: '2025-10-11T16:00:00Z' },
        { week: 8,  home: 'Wisconsin Badgers',    away: 'Ohio State Buckeyes',     date: '2025-10-18T23:00:00Z' },
        { week: 9,  home: 'Bye',                  away: 'Bye',                      date: '2025-10-25' },
        { week: 10, home: 'Ohio State Buckeyes',  away: 'Penn State Nittany Lions',date: '2025-11-01T16:00:00Z' },
        { week: 11, home: 'Purdue Boilermakers',  away: 'Ohio State Buckeyes',     date: '2025-11-08T16:00:00Z' },
        { week: 12, home: 'Ohio State Buckeyes',  away: 'UCLA Bruins',             date: '2025-11-15T16:00:00Z' },
        { week: 13, home: 'Ohio State Buckeyes',  away: 'Rutgers Scarlet Knights', date: '2025-11-22T16:00:00Z' },
        { week: 14, home: 'Michigan Wolverines',  away: 'Ohio State Buckeyes',     date: '2025-11-29T17:00:00Z' },  # Official time announced
        { week: 15, home: 'TBD',                  away: 'TBD',                      date: '2025-12-06T00:00:00Z' }   # Big Ten Championship (8 PM ET = 1 AM UTC Dec 7)
      ]
    }
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
      puts game.inspect
      game['teams']['away']['name'] == team || game['teams']['home']['name'] == team
    end
    { 
      team: team,
      games:
        games.map do |game|
          {
            week: game['season']['week'],
            home: game['teams']['home']['name'],
            away: game['teams']['away']['name'],
            date: game['date']
          }
        end
    }
  end

  def default_schedule_data
    { 
      team: "Cleveland Browns",
      games:
      [
        { week: 1, home: 'Cleveland Browns', away: 'Pittsburgh Steelers', date: '2025-09-07T18:00:00Z' },
        { week: 2, home: 'Baltimore Ravens', away: 'Cleveland Browns', date: '2025-09-14T18:00:00Z' },
        { week: 3, home: 'Cincinatti Bengals', away: 'Cleveland Browns', date: '2025-09-21T18:00:00Z' },
        { week: 4, home: 'Pittsburgh Steelers', away: 'Cleveland Browns', date: '2025-09-28T18:00:00Z' }
      ]
    }
  end
end
