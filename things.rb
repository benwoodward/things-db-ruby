require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'octokit'
require 'json'

DEFAULT_DB="/Users/#{`whoami`.chop}/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application Support/Cultured Code/Things/Things.sqlite3"
GIST_ID=ENV['GIST_ID']
GITHUB_THINGS_TOKEN=ENV['GITHUB_THINGS_TOKEN']
MAX_MINUTES=30

DB = Sequel.sqlite(DEFAULT_DB)

tasks = []

# {
#   :uuid=>"149B52B7-97BD-4D39-923A-BDS6A4733DBC",
#   :trashed=>0,
#   :type=>0,
#   :title=>"test title",
#   :status=>3,
#   :stopDate=>1515566876.735473,
#   :start=>1,
#   :startDate=>1512345600.0,
#   :area=>nil,
#   :project=>nil,
# }

def duration_in_minutes(duration)
  return "15" if duration.nil?

  if duration =~ /m|min/
    minute_string_to_minutes(duration)
  elsif duration =~ /h|hr|hour/
    hour_string_to_minutes(duration)
  end
end

def extract_number_from_string(str)
  str.gsub(/[a-zA-Z]/, '')
end

def minute_string_to_minutes(duration)
  extract_number_from_string(duration)
end

def hour_string_to_minutes(duration)
  hours = extract_number_from_string(duration)
  (hours * 60).to_i
end

def things_url(id)
  "things:///show?id=#{id}"
end



task_rows = DB["
SELECT *
FROM TMTask as TASK
WHERE TASK.trashed = 0 AND TASK.status = 0 AND TASK.type = 0
AND TASK.start = 1
AND TASK.startdate is NOT NULL
ORDER BY TASK.todayIndex
LIMIT 10
"]

combined_duration = 0

task_rows.each do |row|
  duration = duration_in_minutes(row[:duration])

  task = {
    things_url: things_url(row[:uuid]),
    title: row[:title],
    duration: duration
  }

  tasks << JSON.generate(task)

  break if combined_duration >= MAX_MINUTES
  combined_duration += duration.to_i
end

client = Octokit::Client.new(:access_token => GITHUB_THINGS_TOKEN)

output = tasks.join(',')
puts output

client.edit_gist(GIST_ID, {
  files: {"todays_tasks.json" => {content: "[#{output}]"}}
})
