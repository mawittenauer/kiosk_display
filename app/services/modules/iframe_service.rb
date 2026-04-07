# frozen_string_literal: true

class Modules::IframeService
  def initialize(url: nil)
    @url = url
  end

  def iframe_data
    {
      url: sanitized_url,
      title: "Embedded Content"
    }
  rescue => e
    Rails.logger.error "IframeService error: #{e.message}"
    default_iframe_data
  end

  private

  def sanitized_url
    return default_iframe_data[:url] if @url.blank?

    uri = URI.parse(@url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      Rails.logger.warn "IframeService: non-HTTP(S) URL rejected: #{@url}"
      return default_iframe_data[:url]
    end

    @url
  rescue URI::InvalidURIError
    Rails.logger.warn "IframeService: invalid URL rejected: #{@url}"
    default_iframe_data[:url]
  end

  def default_iframe_data
    { url: "about:blank", title: "Embedded Content" }
  end
end
