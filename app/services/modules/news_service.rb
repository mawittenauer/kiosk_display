class Modules::NewsService
  include HTTParty

  #/news/top?api_token=[token]&locale=us&limit=5
  base_uri 'https://api.thenewsapi.com/v1'

  def initialize
    @api_token = ENV['NEWS_API_TOKEN'] || 'your_api_token_here'
  end

  def top_news
    Rails.cache.fetch("top_news", expires_in: 10.minutes) do
      fetch_top_news_data
    end
  rescue => e
    Rails.logger.error "News API Error: #{e.message}"
    default_news_data
  end

  private

  def fetch_top_news_data
    response = self.class.get("/news/top", {
      query: {
        api_token: @api_token,
        locale: 'us',
        limit: 5
      }
    })

    if response.success?
      parse_news_response(response.parsed_response)
    else
      default_news_data
    end
  end

  def parse_news_response(response)
    response['data'].map do |article|
      {
        uuid: article['uuid'],
        title: article['title'],
        description: article['description'],
        keywords: article['keywords'],
        snippet: article['snippet'],
        url: article['url'],
        image_url: article['image_url']
      }
    end
  end

  def default_news_data
    [
      {
        uuid: "b9cf04ab-ea6a-404e-bacd-3574d97b62d4",
        title: "Russia crosses ruble foreign trade threshold",
        description: "The share of the currency has surpassed 50% in all trade regions for the first time, according to the central bank",
        keywords: "",
        snippet: "The share of the currency has surpassed 50% in all trade regions for the first time, according to the central bank\n\nThe share of the Russian ruble in payments f...",
        url: "https:\/\/www.rt.com\/business\/621995-ruble-share-growing\/",
        image_url: "https:\/\/mf.b37mrtl.ru\/files\/2025.07\/article\/68838ecb203027635071fcde.jpg",
        language: "en",
        published_at: "2025-07-25T15:29:45.000000Z",
        source: "rt.com",
        categories:"",
        relevance_score: nil,
        locale: "us"
      },
      {
        uuid: "9714de8d-5a58-4b98-ae30-90571d6ffe54",
        title: "US and Mexico sign accord to combat Tijuana River sewage flowing across the border",
        description: "The United States and Mexico have signed an agreement outlining a plan to clean up the longstanding problem of the Tijuana River pouring sewage across the bor...",
        keywords: "US News, environmental protection agency, lee zeldin, mexico, united states, us border",
        snippet: "The United States and Mexico have signed an agreement outlining specific steps and a new timetable to clean up the longstanding problem of the Tijuana River pou...",
        url: "https:\/\/nypost.com\/2025\/07\/25\/us-news\/us-and-mexico-sign-accord-to-combat-tijuana-river-sewage-flowing-across-the-border\/",
        image_url: "https:\/\/nypost.com\/wp-content\/uploads\/sites\/2\/2025\/07\/108686808.jpg?quality=75&strip=all&w=1024",
        language: "en",
        published_at: "2025-07-25T15:26:16.000000Z",
        source: "nypost.com",
        categories: ["general"],
        relevance_score: nil,
        locale: "us"
      },
      {
        uuid: "813e82cc-4294-49f7-810f-b005a96287c9",
        title: "Jana Kramer Reveals Which Hunting Wives Character She Almost Played",
        description: "'The Hunting Wives' almost looked very different with Jana Kramer almost playing Callie, the role that ultimately went to Jaime Ray Newman",
        keywords: "",
        snippet: "The Hunting Wives almost looked very different.\n\nAfter the Netflix show premiered on Monday, July 21, Jana Kramer, revealed via her Instagram Stories that she w...",
        url: "https:\/\/www.usmagazine.com\/entertainment\/news\/jana-kramer-reveals-which-hunting-wives-character-she-almost-played\/",
        image_url: "https:\/\/www.usmagazine.com\/wp-content\/uploads\/2025\/07\/Feature-Jana-Kramer-Reveals-Which-The-Hunting-Wives-Character-She-Almost-Played-Brittany-Snow-Malin-Akerman.jpg?crop=0px%2C86px%2C2000px%2C1051px&resize=1200%2C630&quality=86&strip=all",
        language: "en",
        published_at: "2025-07-25T15:24:23.000000Z",
        source: "usmagazine.com",
        categories:["entertainment", "general"],
        relevance_score: nil,
        locale: "us"
      }
    ]
  end
end
