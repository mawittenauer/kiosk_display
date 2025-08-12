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
    pages = parse_pages(response.results)
    pages
  end

  def parse_pages(pages)
    pages.map do |page|
      content = @client.page(page_id: page.id)
      properties = content.properties || {}
      {
        id: page.id,
        title: properties['Name']['title'][0] ? properties['Name']['title'][0]['text']['content'] : 'Untitled',
        status: properties['Status'] ? properties['Status']['status']['name'] : 'Unknown',
        impact: properties['Impact']['select'] ? properties['Impact']['select']['name'] : 'None',
        deadline: properties['Deadline']['date'] ? properties['Deadline']['date']['start'] : nil
      }
    end
  end
end
