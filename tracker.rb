require 'rubygems'
require 'asana'
require 'pp'

class AsanaTracker
  # Regex to parse out times in tasks
  MATCH_TIME = /^\[(\d+\.?\d?)\s(hour|hours|minute|minutes|day|days)\]/.freeze

  # Units to figure out computed times
  UNITS = {
    minute:  1,
    minutes: 1,
    hour:    60,
    hours:   60,
    day:     60 * 8,
    days:    60 * 8,
    week:    60 * 8 * 5,
    weeks:   60 * 8 * 5
  }.freeze

  def initialize api_key, workspace_id
    Asana.configure do |client|
      client.api_key = api_key
    end
    @workspace_id = workspace_id
  end

  def workspace
    @workspace ||= Asana::Workspace.find @workspace_id
  end

  def users
    @users ||= workspace.users
  end

  def total_time
    total_time = 0.0
    users.each do |user|
      workspace.tasks(user.id).each do |task|
        time = MATCH_TIME.match task.name
        if time
          count          = time[1]
          unit           = time[2]
          computed_count = count.to_f * UNITS[unit.to_sym]
          total_time     = total_time + computed_count.to_f
        end
      end
    end
    puts "#{(total_time/UNITS[:hours]).round(2)} hours"
    puts "#{(total_time/UNITS[:days]).round(2)} days"
  end
end

tracker = AsanaTracker.new 'gn2PEPr.IlurhIGjsDO7sY6XDSNMsCKQ', 742215140613
tracker.total_time
