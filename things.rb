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

def contains_specified_tags?(tags, tag_names)
  return false if tags.nil?
  tags.select {|tag| tag_names.include?(tag.title) }.count > 0
end

def group_by_time_of_day(tasks)
  morning_tasks = []
  afternoon_tasks = []
  evening_tasks = []
  anytime = []

  tasks.each do |task|
    if contains_specified_tags?(task.tags, ['when:morning'])
      morning_tasks << task
    elsif contains_specified_tags?(task.tags, ['when:afternoon'])
      afternoon_tasks << task
    elsif contains_specified_tags?(task.tags, ['when:evening'])
      evening_tasks << task
    else
      anytime << task
    end
  end

  [morning_tasks, afternoon_tasks, evening_tasks, anytime]
end

def group_by_task_type(tasks)
  return [] if tasks.nil?

  errands = []
  chores = []
  admin = []
  other = []

  tasks.each do |task|
    if contains_specified_tags?(task.tags, ['what:errand', 'what:shopping-trip', 'what:appointment'])
      errands << task
    elsif contains_specified_tags?(task.tags, ['what:chore'])
      chores << task
    elsif contains_specified_tags?(task.tags, ['what:admin', 'what:phonecall', 'what:email', 'what:message'])
      admin << task
    else
      other << task
    end
  end

  admin = group_by_admin_subgroup(admin)

  result = []

  [chores, other, errands, admin].each do |grouping|
    result << grouping if !grouping.empty?
  end

  result
end

def group_by_admin_subgroup(tasks)
  general = []
  phonecalls = []
  messages = []
  emails = []

  tasks.each do |task|
    if contains_specified_tags?(task.tags, ['what:admin'])
      general << task
    elsif contains_specified_tags?(task.tags, ['what:phonecall'])
      phonecalls << task
    elsif contains_specified_tags?(task.tags, ['what:message'])
      messages << task
    elsif contains_specified_tags?(task.tags, ['what:email'])
      emails << task
    end
  end

  result = []

  [emails, messages, phonecalls, general].each do |grouping|
    result << grouping if !grouping.empty?
  end

  result.flatten
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

# Urgent happens first thing
# Then group tasks together by time of day
# Then group tasks by type within those groups
# Then group subgroups into bigger groups
#   Admin:
#     Phonecalls
#     Emails
#     Messages
# Then order tasks by group importance based on whether group contains important item
# Then order groups manually

# Then group tasks together by time of day
morning, afternoon, evening, anytime = group_by_time_of_day(tasks)

# {
#   key: [[], []],
#   key: [[], []]
# }
time_groups = {
  morning: group_by_task_type(morning),
  afternoon: group_by_task_type(afternoon),
  evening: group_by_task_type(evening),
  anytime: group_by_task_type(anytime)
}

# time_groups.each do |name, group|
#   puts "\n\n\n"
#   puts name
#   puts "======="
#   group.each do |item|
#     puts item.map {|item| item.title}
#     puts "---\n\n"
#   end
# end

# should return task groups for each time of the day,
# but arranged so that the most important task groups
# come first

importance_sorted_task_groups = []
# time_groups:
# {
#   key: [[task, task], [task]]
# }
time_groups.each do |time_of_day, task_groups|
  sorted_task_group = ["imp:low", "imp:medium", "imp:high", "imp:urgent"].inject([]) do |sorted_by_tag, tag_name|
    # task_groups:
    # [[task, task], [task]]
    sorted_by_tag = task_groups.inject([]) do |sorted_task_groups, task_group|
      time_group_sorting = []

      # task_group:
      # [task, task]
      all_tags_in_group = task_group.map {|task| task.tags}.flatten

      if contains_specified_tags?(all_tags_in_group, [tag_name])
        time_group_sorting.unshift task_group
      else
        time_group_sorting.push task_group
      end

      sorted_task_groups.push time_group_sorting
    end
  end

  importance_sorted_task_groups.push sorted_task_group
end

# puts "====="
# puts sorted_task_groups.flatten.map {|task| task.title}
# puts "=====\n\n"
importance_sorted_task_groups.flatten.each do |task|
  puts task.title
end

tasks = sorted3_order(importance_sorted_task_groups)

todays_tasks = []
combined_duration = 0

tasks = Task.eager(:tags)
  .where(trashed: 0, status: 0, type: 0, start: 1)
  .where(Sequel.~(startdate: nil))
  .order(:todayIndex)
  .limit(2)

tasks.each do |task|
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

# tasks.each do |task|
#   puts "===Task==="
#   puts task.title
#   puts task.tags.map {|tag| tag.title}.join(',')
# end

# client.edit_gist(GIST_ID, {
  # files: {"todays_tasks.json" => {content: "[#{output}]"}}
# })
