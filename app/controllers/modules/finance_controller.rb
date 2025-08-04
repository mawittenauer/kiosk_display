class Modules::FinanceController < ApplicationController
  def index
    render json: {
      stock_prices: finance_service.stock_prices
    }
  end

  def stock_prices
    render json: finance_service.stock_prices
  end

  private

  def finance_service
    @finance_service ||= Modules::FinanceService.new.stock_prices(params[:symbols] || ['AAPL', 'GOOGL', 'MSFT'])
  end
end
