class Modules::NotionController < ApplicationController
  def index
    render json: notion_service.pages
  end

  private

  def notion_service
    @notion_service ||= Modules::NotionService.new
  end
end
