class Modules::FinanceService
  include HTTParty

  base_uri 'https://financialdata.net/api/v1'

  def initialize
    @api_key = ENV['FINANCE_API_KEY'] || 'your_api_key_here'
  end

  def stock_prices(symbols)
    Rails.cache.fetch("stock_price_#{symbols}", expires_in: 10.minutes) do
      fetch_multiple_stock_data(symbols)
    end
  rescue => e
    Rails.logger.error "Finance API Error: #{e.message}"
    [default_stock_data] * symbols.size
  end

  private

  def fetch_stock_data(symbol)
    response = self.class.get("/stock-prices", {
      query: {
        identifier: symbol,
        key: @api_key
      }
    })

    if response.success? && response.parsed_response.length > 0
      parse_stock_response(response.parsed_response)
    else
      default_stock_data
    end
  end

  def fetch_multiple_stock_data(symbols)
    responses = symbols.map do |symbol|
      Rails.cache.fetch("stock_price_#{symbol}", expires_in: 10.minutes) do
        fetch_stock_data(symbol)
      end
    end

    responses.compact
  rescue => e
    Rails.logger.error "Finance API Error: #{e.message}"
    [default_stock_data] * symbols.size
  end

  def parse_stock_response(data)
    {
      trading_symbol: data[0]['trading_symbol'],
      date: data[0]['date'],
      open: data[0]['open'].to_f,
      high: data[0]['high'].to_f,
      low: data[0]['low'].to_f,
      close: data[0]['close'].to_f,
      volume: data[0]['volume'].to_f
    }
  end

  def default_stock_data
    {
      trading_symbol: "AAPL",
      date: "2025-08-01",
      open: 210.865,
      high: 213.58,
      low: 201.5,
      close: 202.38,
      volume: 104434500.0
    }
  end
end
