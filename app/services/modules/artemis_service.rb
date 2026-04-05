class Modules::ArtemisService
  include HTTParty

  base_uri "https://ll.thespacedevs.com/2.3.0"

  ARTEMIS_2_SLUG = "artemis-2"

  CREW = [
    { name: "Reid Wiseman", role: "Commander", agency: "NASA", nationality: "USA" },
    { name: "Victor Glover", role: "Pilot", agency: "NASA", nationality: "USA" },
    { name: "Christina Koch", role: "Mission Specialist 1", agency: "NASA", nationality: "USA" },
    { name: "Jeremy Hansen", role: "Mission Specialist 2", agency: "CSA", nationality: "Canada" }
  ].freeze

  MILESTONES = [
    { name: "SLS Core Stage Stacking", date: "2024-11-20", completed: true },
    { name: "Orion Spacecraft Mating", date: "2025-01-15", completed: true },
    { name: "Integrated Vehicle Testing", date: "2025-06-01", completed: true },
    { name: "Flight Readiness Review", date: "2025-09-10", completed: true },
    { name: "Crew Equipment Interface Test", date: "2025-11-01", completed: true },
    { name: "Wet Dress Rehearsal", date: "2026-02-15", completed: true },
    { name: "Launch Readiness Review", date: "2026-04-20", completed: false },
    { name: "Launch", date: "2026-04-25T17:30:00Z", completed: false },
    { name: "Trans-Lunar Injection", date: "2026-04-25T19:30:00Z", completed: false },
    { name: "Lunar Flyby", date: "2026-04-29", completed: false },
    { name: "Return & Splashdown", date: "2026-05-05", completed: false }
  ].freeze

  def initialize
    # No API key required for Launch Library 2 (free tier)
  end

  def mission_data
    Rails.cache.fetch("artemis2/mission", expires_in: 30.minutes) do
      fetch_mission_data
    end
  rescue => e
    Rails.logger.error "ArtemisService error: #{e.message}"
    default_mission_data
  end

  private

  def fetch_mission_data
    response = self.class.get("/launch/upcoming/", {
      query: { search: "Artemis II", limit: 1, format: "json" },
      timeout: 10
    })

    if response.success? && response.parsed_response["results"]&.any?
      parse_launch_response(response.parsed_response["results"].first)
    else
      default_mission_data
    end
  rescue => e
    Rails.logger.error "ArtemisService API error: #{e.message}"
    default_mission_data
  end

  def parse_launch_response(launch)
    launch_date = launch["net"] || launch["window_start"]
    status_name = launch.dig("status", "name") || "Unknown"

    {
      mission_name: "Artemis II",
      description: launch.dig("mission", "description") || default_description,
      status: status_name,
      launch_date: launch_date,
      vehicle: launch.dig("rocket", "configuration", "full_name") || "SLS Block 1",
      pad: launch.dig("pad", "name") || "LC-39B, Kennedy Space Center",
      image: launch["image"] || nil,
      crew: CREW,
      milestones: MILESTONES,
      last_updated: Time.current.strftime("%I:%M %p")
    }
  end

  def default_mission_data
    {
      mission_name: "Artemis II",
      description: default_description,
      status: "Go For Launch",
      launch_date: "2026-04-25T17:30:00Z",
      vehicle: "SLS Block 1 Crew",
      pad: "LC-39B, Kennedy Space Center",
      image: nil,
      crew: CREW,
      milestones: MILESTONES,
      last_updated: Time.current.strftime("%I:%M %p")
    }
  end

  def default_description
    "NASA's Artemis II mission will send four astronauts on a trajectory around the Moon and back, " \
    "marking humanity's first crewed voyage to lunar distance since Apollo 17 in 1972. " \
    "The crew will fly aboard the Orion spacecraft launched by the Space Launch System (SLS) rocket."
  end
end
