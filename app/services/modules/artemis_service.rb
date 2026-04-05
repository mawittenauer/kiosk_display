class Modules::ArtemisService
  LAUNCH_TIME = Time.utc(2026, 4, 1, 16, 0, 0) # April 1, 2026 12:00 PM EDT

  CREW = [
    { name: "Reid Wiseman", role: "Commander", agency: "NASA" },
    { name: "Victor Glover", role: "Pilot", agency: "NASA" },
    { name: "Christina Koch", role: "MS-1", agency: "NASA" },
    { name: "Jeremy Hansen", role: "MS-2", agency: "CSA" }
  ].freeze

  # Mission phases with hours-from-launch boundaries
  # Artemis II is a ~10 day free-return lunar flyby
  MISSION_PHASES = [
    { key: "launch",     label: "Launch & Ascent",       start_h: 0,    end_h: 2,     icon: "🚀" },
    { key: "tli",        label: "Trans-Lunar Injection",  start_h: 2,    end_h: 4,     icon: "🔥" },
    { key: "outbound",   label: "Outbound Coast",         start_h: 4,    end_h: 96,    icon: "🌑" },
    { key: "flyby",      label: "Lunar Flyby",            start_h: 96,   end_h: 120,   icon: "🌕" },
    { key: "return",     label: "Return Coast",           start_h: 120,  end_h: 228,   icon: "🌍" },
    { key: "reentry",    label: "Re-entry & Splashdown",  start_h: 228,  end_h: 240,   icon: "🪂" },
    { key: "complete",   label: "Mission Complete",        start_h: 240,  end_h: nil,   icon: "✅" }
  ].freeze

  MILESTONES = [
    { name: "Launch",                    time: LAUNCH_TIME,                       completed: true },
    { name: "Trans-Lunar Injection",     time: LAUNCH_TIME + 2.hours,             completed: true },
    { name: "Outbound Coast Begins",     time: LAUNCH_TIME + 4.hours,             completed: true },
    { name: "Lunar Flyby",              time: LAUNCH_TIME + 96.hours,             completed: false },
    { name: "Return Coast Begins",       time: LAUNCH_TIME + 120.hours,           completed: false },
    { name: "Re-entry & Splashdown",     time: LAUNCH_TIME + 234.hours,           completed: false }
  ].freeze

  def initialize
    # No external API keys required — mission data is deterministic
  end

  def mission_data
    Rails.cache.fetch("artemis2/mission", expires_in: 10.minutes) do
      build_mission_data
    end
  rescue => e
    Rails.logger.error "ArtemisService error: #{e.message}"
    default_mission_data
  end

  private

  def build_mission_data
    now = Time.current
    elapsed_h = ((now - LAUNCH_TIME) / 1.hour).round(2)
    phase = current_phase(elapsed_h)
    total_duration_h = 240.0

    milestones_with_status = MILESTONES.map do |ms|
      { name: ms[:name], time: ms[:time].iso8601, completed: now >= ms[:time] }
    end

    {
      mission_name: "Artemis II",
      status: phase[:label],
      status_icon: phase[:icon],
      phase_key: phase[:key],
      launch_time: LAUNCH_TIME.iso8601,
      elapsed_hours: elapsed_h,
      progress_pct: [ ((elapsed_h / total_duration_h) * 100).round(1), 100.0 ].min,
      vehicle: "SLS Block 1 Crew",
      crew: CREW,
      milestones: milestones_with_status,
      phases: MISSION_PHASES.map { |p| { key: p[:key], label: p[:label], icon: p[:icon], active: p[:key] == phase[:key] } },
      next_milestone: milestones_with_status.find { |m| !m[:completed] },
      last_updated: now.strftime("%I:%M %p")
    }
  end

  def current_phase(elapsed_h)
    return MISSION_PHASES.first if elapsed_h < 0

    MISSION_PHASES.find do |p|
      p[:end_h].nil? || (elapsed_h >= p[:start_h] && elapsed_h < p[:end_h])
    end || MISSION_PHASES.last
  end

  def default_mission_data
    {
      mission_name: "Artemis II",
      status: "In Flight",
      status_icon: "🚀",
      phase_key: "outbound",
      launch_time: LAUNCH_TIME.iso8601,
      elapsed_hours: 0,
      progress_pct: 0,
      vehicle: "SLS Block 1 Crew",
      crew: CREW,
      milestones: MILESTONES.map { |ms| { name: ms[:name], time: ms[:time].iso8601, completed: false } },
      phases: MISSION_PHASES.map { |p| { key: p[:key], label: p[:label], icon: p[:icon], active: false } },
      next_milestone: nil,
      last_updated: Time.current.strftime("%I:%M %p")
    }
  end
end
