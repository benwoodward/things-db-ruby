require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'octokit'
require 'json'

DEFAULT_DB="/Users/#{`whoami`.chop}/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application Support/Cultured Code/Things/Things.sqlite3"
DB = Sequel.sqlite(DEFAULT_DB)

GIST_ID=ENV['GIST_ID']
GITHUB_THINGS_TOKEN=ENV['GITHUB_THINGS_TOKEN']
MAX_MINUTES=8*60

def duration_in_minutes(tags)
  dur_tag = tags.select {|tag| tag.title =~ /dur:/}.first
  if dur_tag.nil?
    return 15
  else
    extract_minutes_from_dur_string(dur_tag.title)
  end
end

def extract_minutes_from_dur_string(str)
  if str =~ /m|min/
    minute_string_to_minutes(str)
  elsif str =~ /h|hr|hour/
    hour_string_to_minutes(str)
  end
end

def extract_number_from_string(str)
  str.gsub(/[a-zA-Z:]/, '').to_i
end

def minute_string_to_minutes(duration)
  extract_number_from_string(duration)
end

def hour_string_to_minutes(duration)
  hours = extract_number_from_string(duration)
  (hours.to_i * 60).to_i
end

def things_url(id)
  "things:///show?id=#{id}"
end

class Task < Sequel::Model(DB[:TMTask])
  many_to_many :tags, left_key: :tasks, right_key: :tags,
    join_table: :TMTaskTag
end

class Tag < Sequel::Model(DB[:TMTag])
  many_to_many :tasks, left_key: :tags, right_key: :tasks,
    join_table: :TMTaskTag
end

def contains_urgent_tag?(tags)
  tags.select {|tag| tag.title == 'imp:URGENT!'}.count > 0
end

def contains_high_imp_tag?(tags)
  tags.select {|tag| tag.title == 'imp:high'}.count > 0
end

def contains_med_imp_tag?(tags)
  tags.select {|tag| tag.title == 'imp:medium'}.count > 0
end

def order_by_importance(tasks)
  [:contains_med_imp_tag?, :contains_high_imp_tag?, :contains_urgent_tag?].inject(tasks) do |reordered_tasks, filter_method|
    reordered_tasks = apply_filter(reordered_tasks, filter_method)
  end
end

def apply_filter(tasks, filter_method)
  tasks.partition do |task|
    self.send filter_method, task.tags
  end.flatten
end

def task_content(task)
  newline_char = "\n"
  "#{task[:title]}#{newline_char}#{things_url(task[:uuid])}#{newline_char}#{task[:notes]}"
end

tasks = Task.eager(:tags)
  .where(trashed: 0, status: 0, type: 0, start: 1)
  .where(Sequel.~(startdate: nil))
  .order(:todayIndex)
  .limit(100)

def sorted3_order(tasks)
  first_item = [tasks[0]]
  reversed_list = tasks.drop(1).reverse
  first_item + reversed_list
end

ordered_by_importance = order_by_importance(tasks)
reordered_for_sorted_position_2_bug = sorted3_order(ordered_by_importance)

todays_tasks = []
combined_duration = 0

reordered_for_sorted_position_2_bug.each do |task|
  duration = duration_in_minutes(task.tags)

  task = {
    things_url: things_url(task[:uuid]),
    content: task_content(task),
    duration: duration
  }

  todays_tasks << JSON.generate(task)

  break if combined_duration >= MAX_MINUTES
  combined_duration += duration.to_i
end


client = Octokit::Client.new(:access_token => GITHUB_THINGS_TOKEN)

output = todays_tasks.join(',')

ordered_by_importance.each do |task|
  puts task.title
end

client.edit_gist(GIST_ID, {
  files: {"todays_tasks.json" => {content: "[#{output}]"}}
})
