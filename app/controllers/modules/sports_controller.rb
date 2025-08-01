class Modules::SportsController < ApplicationController
  def index
    render json: {
      schedule: sports_service.schedule(params[:team] || 'Cleveland Browns')
    }
  end

  def schedule
    team_name = params[:team] || 'Cleveland Browns'
    render json: sports_service.schedule(team_name)
  end

  private

  def sports_service
    @sports_service ||= Modules::SportsService.new(params[:year] || '2025')
  end
end