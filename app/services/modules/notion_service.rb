class Modules::NotionService
  def initialize
    @client = Notion::Client.new(token: ENV['NOTION_API_KEY'])
    @database_key = ENV['NOTION_DATABASE_KEY']
  end

  def pages
    puts @database_key.inspect
    Rails.cache.fetch("notion_pages", expires_in: 30.minutes) do
      fetch_pages
    end
  rescue => e
    Rails.logger.error "Notion API Error: #{e.message}"
    []
  end

  private
  def fetch_pages
    response = @client.database_query(database_id: @database_key)
    puts response.inspect
    response
  end
end
