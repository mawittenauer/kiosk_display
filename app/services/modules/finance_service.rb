class Modules::FinanceService
  include HTTParty

  base_uri 'https://financialdata.net/api/v1'

  def initialize
    @api_key = ENV['FINANCE_API_KEY'] || 'your_api_key_here'
  end

  def stock_price(symbol)
    Rails.cache.fetch("stock_price_#{symbol}", expires_in: 10.minutes) do
      fetch_stock_data(symbol)
    end
  rescue => e
    Rails.logger.error "Finance API Error: #{e.message}"
    default_stock_data
  end

  private

  def fetch_stock_data(symbol)
    response = self.class.get("/stock-price", {
      query: {
        identifier: symbol,
        key: @api_key
      }
    })

    if response.success?
      parse_stock_response(response.parsed_response)
    else
      default_stock_data
    end
  end

  def parse_stock_response(data)
    data.map do |item|
      {
        trading_symbol: item['trading_symbol'],
        date: item['date'],
        open: item['open'].to_f,
        high: item['high'].to_f,
        low: item['low'].to_f,
        close: item['close'].to_f,
        volume: item['volume'].to_f
      }
    end
  end

  def default_stock_data
    [
      {
        trading_symbol: "AAPL",
        date: "2025-08-01",
        open: 210.865,
        high: 213.58,
        low: 201.5,
        close: 202.38,
        volume: 104434500.0
      },
      {
        trading_symbol: "AAPL",
        date: "2025-07-31",
        open: 208.49,
        high: 209.84,
        low: 207.16,
        close: 207.57,
        volume: 80698430.0
      },
      {
        trading_symbol: "AAPL",
        date: "2025-07-30",
        open: 211.895,
        high: 212.39,
        low: 207.72,
        close: 209.05,
        volume: 45512510.0
      },
      {
        trading_symbol: "AAPL",
        date: "2025-07-29",
        open: 214.175,
        high: 214.81,
        low: 210.82,
        close: 211.27,
        volume: 51411720.0
      }
    ]
  end
end
