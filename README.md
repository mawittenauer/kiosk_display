## Kiosk Display Application

A modular Ruby on Rails application designed for kiosk displays, starting with a weather module.

### Setup Instructions

1. **Create the Rails app:**
   ```bash
   rails new kiosk_display
   cd kiosk_display
   ```

2. **Add gems to Gemfile and install:**
   ```bash
   bundle install
   ```

3. **Generate and run migrations:**
   ```bash
   rails generate migration CreateKioskConfigs
   # Copy the migration content from above
   rails db:migrate
   ```

4. **Set up OpenWeather API:**
   - Sign up at https://openweathermap.org/api
   - Get your free API key
   - Add to environment variables:
   ```bash
   echo 'export OPENWEATHER_API_KEY="your_api_key_here"' >> ~/.bashrc
   source ~/.bashrc
   ```

5. **Create directories and files:**
   ```bash
   mkdir -p app/services/modules
   mkdir -p app/views/modules/weather
   # Copy all the files from the code above into their respective locations
   ```

6. **Start the server:**
   ```bash
   rails server -b 0.0.0.0 -p 3000
   ```

### Raspberry Pi Kiosk Mode Setup

1. **Install Chromium in kiosk mode:**
   ```bash
   sudo apt update
   sudo apt install chromium-browser
   ```

2. **Create kiosk startup script:**
   ```bash
   # /home/pi/start_kiosk.sh
   #!/bin/bash
   chromium-browser --kiosk --disable-infobars --disable-session-crashed-bubble --disable-component-extensions-with-background-pages --disable-background-networking --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows --no-first-run --disable-dev-shm-usage --disable-gpu --no-sandbox http://localhost:3000
   ```

3. **Make executable and add to autostart:**
   ```bash
   chmod +x /home/pi/start_kiosk.sh
   echo '@/home/pi/start_kiosk.sh' >> ~/.config/lxsession/LXDE-pi/autostart
   ```

### Configuration

Access the configuration API at:
- GET `/kiosk_configs` - View current config
- PUT `/kiosk_configs` - Update config

Example config update:
```bash
curl -X PUT http://localhost:3000/kiosk_configs \
  -H "Content-Type: application/json" \
  -d '{
    "kiosk_config": {
      "zipcode": "44503",
      "refresh_interval": 300000,
      "modules_enabled": ["weather"]
    }
  }'
```

### Adding New Modules

1. Create service class in `app/services/modules/`
2. Create controller in `app/controllers/modules/`
3. Create view partial in `app/views/modules/module_name/`
4. Add routes in `config/routes.rb`
5. Update `KioskController#load_enabled_modules` method

### Weather Module Features

- Real-time weather data from OpenWeatherMap
- Displays temperature, feels-like, humidity
- Weather icons and descriptions
- Auto-refresh every 5 minutes (configurable)
- Caching to prevent API rate limits
- Fallback data when API unavailable