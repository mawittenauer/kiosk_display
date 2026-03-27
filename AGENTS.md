# Kiosk Display — Agent Instructions

## Project Overview

`kiosk_display` is a **Ruby on Rails 7.2** application that renders a full-screen information dashboard for an unattended kiosk device (e.g., a Raspberry Pi running Chromium in kiosk mode). It aggregates data from multiple external APIs — weather, news, finance, sports, network, and Notion — and displays them as glassmorphism-styled tiles on a single page. The UI is cursor-free and auto-refreshing.

---

## Tech Stack

- **Framework:** Ruby on Rails 7.2
- **Database:** SQLite3 (all environments via `storage/*.sqlite3`)
- **Asset Pipeline:** Sprockets + Importmap (no Node/bundler)
- **JS Framework:** Hotwire (Turbo + Stimulus)
- **HTTP Client:** `httparty` for all external API calls
- **Server:** Puma
- **Deployment:** Docker (Dockerfile at root); targets a local/LAN server or Raspberry Pi
- **Testing:** Minitest (Rails default) + Capybara + Selenium for system tests
- **Linting:** RuboCop (`rubocop-rails-omakase`), Brakeman for security

---

## Repository Structure

```
app/
  controllers/
    application_controller.rb       # Singleton kiosk_config helper (before_action)
    kiosk_controller.rb             # Root page — loads & renders all enabled modules
    kiosk_configs_controller.rb     # CRUD for the singleton KioskConfig (JSON API)
    modules/                        # One controller per module (namespaced)
      finance_controller.rb
      flights_controller.rb
      network_controller.rb
      news_controller.rb
      notion_controller.rb
      sports_controller.rb
      weather_controller.rb
  models/
    kiosk_config.rb                 # Singleton config model (see Singleton Pattern below)
  services/
    modules/                        # One service class per external integration
      finance_service.rb
      network_service.rb
      news_service.rb
      notion_service.rb
      sports_service.rb
      weather_service.rb
  views/
    layouts/application.html.erb    # Full-viewport dark layout, no cursor, glassmorphism cards
    kiosk/index.html.erb            # Main display: grid of module tiles + live clock + JS refresh
    modules/                        # One partial per module: _display.html.erb
      finance/_display.html.erb
      flights/_display.html.erb
      network/_display.html.erb
      news/_display.html.erb
      notion/_display.html.erb
      sports/_display.html.erb      # Shared partial for both NFL and Buckeyes tiles
      weather/_display.html.erb
config/
  routes.rb                         # Root + namespaced :modules resources + kiosk_configs
db/
  schema.rb                         # Single table: kiosk_configs
  seeds.rb
```

---

## Key Architectural Patterns

### 1. Singleton Config (`KioskConfig`)

There is exactly one row in `kiosk_configs`. Access it exclusively via:
```ruby
KioskConfig.instance  # class method — finds or creates the single row
```
Never call `KioskConfig.find`, `KioskConfig.new`, or `KioskConfig.create` directly.

The model has these columns:
| Column | Type | Default | Notes |
|---|---|---|---|
| `zipcode` | string | `"44514"` | 5-digit ZIP for weather |
| `refresh_interval` | integer | `300000` | Client-side refresh in **milliseconds** |
| `enabled_modules` | text | serialized list | Names of active module tiles |

### 2. `ApplicationController#kiosk_config`

Defined as a `helper_method` and set via `before_action`. It memoises `KioskConfig.instance` into `@kiosk_config`. All controllers and views should use `kiosk_config` (not query the model directly).

### 3. Module Loading (`KioskController#load_enabled_modules`)

Reads `kiosk_config.enabled_modules` (or overrides from `params[:modules]` comma-separated) and builds:
```ruby
@modules = [{ name:, partial:, data: }, ...]
```
`kiosk/index.html.erb` iterates `@modules` and renders each `partial` with local `data:`.

### 4. Service Layer Pattern

Every external API integration lives in `app/services/modules/<name>_service.rb`. All services share the same structure:
```ruby
class Modules::WeatherService
  def initialize(zipcode: nil)   # optional constructor args
    @api_key = ENV['OPENWEATHER_API_KEY']
  end

  def current_weather            # public methods called by controllers
    Rails.cache.fetch('weather/current', expires_in: 10.minutes) do
      fetch_current_data
    end
  rescue => e
    Rails.logger.error "WeatherService error: #{e.message}"
    default_current_data         # always return safe fallback
  end

  private

  def fetch_current_data; end    # HTTParty call
  def parse_current_response; end
  def default_current_data; end  # hardcoded safe fallback hash/array
end
```

**Rules when adding a new service:**
- Constructor reads all ENV vars needed.
- All public methods are wrapped in a `rescue` block that logs and returns default data.
- Cache all external calls with `Rails.cache.fetch` — use 10-minute TTL by default, 30 minutes for slower-changing data (e.g., Notion).
- Return plain Ruby hashes/arrays (no ActiveRecord objects).

### 5. Module Controller Pattern

Each module controller under `app/controllers/modules/` follows this pattern:
```ruby
module Modules
  class WeatherController < ApplicationController
    def index
      render json: current_weather
    end

    def current
      render json: current_weather
    end

    private

    def weather_service
      @weather_service ||= Modules::WeatherService.new(
        zipcode: params[:zipcode] || kiosk_config.zipcode
      )
    end

    def current_weather
      weather_service.current_weather
    end
  end
end
```

**Rules:**
- Memoize the service instance with `||=`.
- Delegate to the service for all data fetching — no HTTParty calls in controllers.
- Render JSON for all module controller actions (these are AJAX endpoints).

### 6. View / Partial Pattern

Each module has exactly one partial at `app/views/modules/<name>/_display.html.erb`. The partial receives `data` as a local variable from `kiosk/index.html.erb`:
```erb
<%= render partial: module[:partial], locals: { data: module[:data] } %>
```
Partials should gracefully handle `nil`/empty `data` (the service fallback guarantees a baseline structure, but defensive `&.` or `|| 'N/A'` guards are encouraged).

### 7. Client-Side Auto-Refresh

`kiosk/index.html.erb` contains inline JS that calls the module JSON endpoints on a `setInterval` driven by `kiosk_config.refresh_interval` (milliseconds). DOM is updated without a full page reload. When adding a new module that needs live updates, add a corresponding `updateXxx()` JS function and register it in the interval.

---

## Routes Reference

```ruby
root "kiosk#index"

namespace :modules do
  resources :weather,  only: [:index, :show] do
    collection { get :current; get :forecast }
  end
  resources :network,  only: [:index] do
    collection { get :devices }
  end
  resources :flights,  only: [:index] do
    collection { get :flights }
  end
  resources :news,     only: [:index] do
    collection { get :top_news }
  end
  resources :sports,   only: [:index] do
    collection { get :schedule }
  end
  resources :notion,   only: [:index]
  resources :finance,  only: [:index] do
    collection { get :stock_prices }
  end
end

resources :kiosk_configs, only: [:index, :create, :update]
```

---

## Environment Variables

| Variable | Service | Required? |
|---|---|---|
| `OPENWEATHER_API_KEY` | WeatherService | Yes |
| `NEWS_API_TOKEN` | NewsService | Yes |
| `SPORTS_API_KEY` | SportsService | Yes |
| `FINANCE_API_KEY` | FinanceService | Yes |
| `NOTION_API_KEY` | NotionService | Yes |
| `NOTION_DATABASE_KEY` | NotionService | Yes |

All ENV vars are read in service constructors. The app starts and renders fallback data even when keys are missing (services catch errors and return `default_*_data`).

---

## Database

- SQLite3 only — no PostgreSQL or MySQL.
- Single table: `kiosk_configs`.
- Migrations live in `db/migrate/`. Always run `rails db:migrate` after adding migrations.
- Seeds (`db/seeds.rb`) should create the singleton config if it doesn't exist:
  ```ruby
  KioskConfig.instance
  ```

---

## Adding a New Module — Checklist

1. **Service:** `app/services/modules/<name>_service.rb` — follow the service pattern above.
2. **Controller:** `app/controllers/modules/<name>_controller.rb` — follow the module controller pattern.
3. **Partial:** `app/views/modules/<name>/_display.html.erb` — receive `data:` local.
4. **Route:** Add `resources :<name>, only: [...]` inside `namespace :modules`.
5. **KioskController:** Add a `when '<name>'` branch in `load_enabled_modules` that instantiates the service, calls the right method, and pushes `{ name:, partial: 'modules/<name>/display', data: }` onto `@modules`.
6. **KioskConfig:** Add `'<name>'` to the `enabled_modules` default list if it should be on by default.
7. **JS refresh (optional):** Add an `updateXxx()` function and `setInterval` call in `kiosk/index.html.erb` if the tile needs live polling.
8. **Tests:** Add controller test in `test/controllers/modules/<name>_controller_test.rb`.

---

## Testing

- Framework: Minitest (Rails default).
- Test files mirror the `app/` directory under `test/`.
- Run all tests: `rails test`
- Run system tests: `rails test:system`
- Fixtures in `test/fixtures/`.
- Security scan: `bin/brakeman`
- Lint: `bin/rubocop`

---

## Code Style

- Follow `rubocop-rails-omakase` defaults (essentially the Basecamp/Rails style guide).
- Use `frozen_string_literal: true` at the top of Ruby files where appropriate.
- Prefer `&.` safe navigation over explicit nil guards.
- No inline JS in partials — keep JS in `kiosk/index.html.erb` or Stimulus controllers.
- No direct `HTTParty` calls outside of service classes.

---

## Deployment Notes

- A `Dockerfile` is present at the repo root for containerised deployment.
- The `docker-entrypoint` script is at `bin/docker-entrypoint`.
- Production uses `production.sqlite3` (file-based, persisted via volume mount).
- The `NetworkService` targets a hardcoded LAN address (`192.168.1.51:3001`) — this is a co-located home network scanner; do not change without also updating that service.
- PWA support is included (service worker + manifest routes).
