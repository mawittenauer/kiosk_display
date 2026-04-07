# frozen_string_literal: true

module Modules
  class IframeController < ApplicationController
    def index
      render json: iframe_data
    end

    private

    def iframe_service
      @iframe_service ||= Modules::IframeService.new(url: params[:url])
    end

    def iframe_data
      iframe_service.iframe_data
    end
  end
end
