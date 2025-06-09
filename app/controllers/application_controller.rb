class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private
  
  def kiosk_config
    @kiosk_config ||= KioskConfig.first_or_create(
      zipcode: '44514',
      refresh_interval: 300000, # 5 minutes in milliseconds
      modules_enabled: ['weather']
    )
  end
  helper_method :kiosk_config
end
