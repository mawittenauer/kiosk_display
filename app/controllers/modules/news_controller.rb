class Modules::NewsController < ApplicationController
  def index
    render json: { top_news: news_service.top_news }
  end

  def top_news
    render json: news_service.top_news
  end

  private

  def news_service
    @news_service ||= Modules::NewsService.new
  end
end
