class Modules::NetworkService
  include HTTParty

  base_uri 'http://192.168.1.51:3001/network/devices/all'

  def devices
    Rails.cache.fetch("network_devices", expires_in: 10.minutes) do
      fetch_devices_data
    end
  rescue => e
    Rails.logger.error "Network API Error: #{e.message}"
    default_devices_data
  end

  private

  def fetch_devices_data
    response = self.class.get('')

    if response.success?
      parse_devices_response(response.parsed_response)
    else
      default_devices_data
    end
  end

  def parse_devices_response(data)
    cutoff = 6.hours.ago
    data.select do |device|
      last_seen = device['last_seen']
      ip = device['ip_address']
      next false unless last_seen.present? && ip.present? && ip != '0.0.0.0'
      begin
        Time.parse(last_seen) >= cutoff
      rescue ArgumentError
        false
      end
    end.map do |device|
      {
        name: device['name'],
        friendly_name: device['friendly_name'] || 'Unknown Device',
        ip_address: device['ip_address'],
        mac_address: device['mac_address'],
        last_seen: device['last_seen'] || 'N/A'
      }
    end
  end

  def default_devices_data
    [
      {
        name: 'Unknown Device',
        friendly_name: 'Unknown Device',
        ip: ' N/A',
        mac_address: 'N/A',
        last_seen: 'N/A'
      }
    ]
  end
end
