require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'octokit'
require 'json'

require './config'
require './models/tag'
require './models/task'



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



def contains_specified_tags?(tags, tag_names)
  return false if tags.nil?
  tags.select {|tag| tag_names.include?(tag.title) }.count > 0
end

def group_by_time_of_day(tasks)
  first_things = []
  morning_tasks = []
  afternoon_tasks = []
  evening_tasks = []
  anytime = []

  tasks.each do |task|
    if contains_specified_tags?(task.tags, ['when:first-thing'])
      first_things << task
    elsif contains_specified_tags?(task.tags, ['when:morning'])
      morning_tasks << task
    elsif contains_specified_tags?(task.tags, ['when:afternoon'])
      afternoon_tasks << task
    elsif contains_specified_tags?(task.tags, ['when:evening'])
      evening_tasks << task
    else
      anytime << task
    end
  end

  [first_things, morning_tasks, anytime, afternoon_tasks, evening_tasks]
end

def group_by_task_type(tasks)
  return [] if tasks.nil?

  errands = []
  chores = []
  admin = []
  focussed_work = []
  downtime = []
  other = []

  tasks.each do |task|
    if contains_specified_tags?(task.tags, ['what:errand', 'what:shopping-trip', 'what:appointment'])
      errands << task
    elsif contains_specified_tags?(task.tags, ['what:chore'])
      chores << task
    elsif contains_specified_tags?(task.tags, ['what:admin', 'what:phonecall', 'what:email', 'what:message'])
      admin << task
    elsif contains_specified_tags?(task.tags, ['what:focussed-work', 'what:code', 'what:research'])
      focussed_work << task
    elsif contains_specified_tags?(task.tags, ['what:downtime', 'what:to-watch', 'what:to-read'])
      downtime << task
    else
      other << task
    end
  end

  admin = group_by_admin_subgroup(admin)

  result = []

  [chores, focussed_work, other, errands, admin, downtime].each do |grouping|
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

def db_tasks
  Task.eager(:tags)
    .where(trashed: 0, status: 0, type: 0, start: 1)
    .where(Sequel.~(startdate: nil))
    .order(:todayIndex)
    .limit(100)
end

def sorted3_order(tasks)
  first_item = [tasks[0]]
  reversed_list = tasks.drop(1).reverse
  first_item + reversed_list
end

# {
#   key: [[], []],
#   key: [[], []]
# }
def time_groups(tasks)
  # group tasks together by time of day
  first_things, morning, afternoon, evening, anytime = group_by_time_of_day(tasks)

  [
    group_by_task_type(first_things),
    group_by_task_type(morning),
    group_by_task_type(afternoon),
    group_by_task_type(evening),
    group_by_task_type(anytime)
  ]
end


# time_groups.each do |time_group|
#   puts "\n::::TIME GROUP::::"
#   puts "======="
#   time_group.each do |task_group|
#     puts "\n::::task group::::"
#     puts "======="
#     task_group.each do |task|
#       puts task.title
#     end
#   end
#   puts "\n\n"
# end

def sort_task_group(task_group)
  ["imp:low", "imp:medium", "imp:high", "imp:urgent"].inject(task_group) do |reordered_tasks, tag_name|
    reordered_tasks.partition do |task|
      contains_specified_tags?(task.tags, [tag_name])
    end.flatten
  end
end

def task_importance_sorted_time_groups(time_groups)
  time_groups.inject([]) do |updated_time_groups, time_group|
    updated_time_group = []
    time_group.each do |task_group|
      sorted_task_group = sort_task_group(task_group)
      updated_time_group << sorted_task_group
    end
    updated_time_groups << updated_time_group
  end
end

# should return task groups for each time of the day,
# but arranged so that the most important task groups
# come first

# time_groups:
# {
#   [[task, task], [task]]
# }
# for each time_group, order the task_groups by each imp: tag, based on whether
# a task group contains a task with that tag
#
# TODO: Make this less of a headfuck to read; refactor into small sensibly-named methods
def importance_sorted_task_groups(tasks)
  tasks.inject([]) do |sorted_time_groups, time_group|
    sorted_time_group = ["imp:low", "imp:medium", "imp:high", "imp:urgent"].inject(time_group) do |sorted_task_groups, tag_name|

      new_sorting = sorted_task_groups
      # task_groups:
      # [[task, task], [task]]
      sorted_task_groups.each_with_index do |task_group, index|

        # task_group:
        # [task, task]
        all_tags_in_group = task_group.map {|task| task.tags}.flatten

        # move those with tag to front on each operation, otherwise leave where they are
        if contains_specified_tags?(all_tags_in_group, [tag_name])
          new_sorting.delete_at(index)
          new_sorting.unshift task_group
        end
      end

      new_sorting
    end

    sorted_time_groups << sorted_time_group
  end
end

# importance_sorted_task_groups.each do |time_group|
#   puts "\n::::IMP. Sorted TIME GROUP::::"
#   puts "======="
#   time_group.each do |task_group|
#     puts "\n::::task group::::"
#     puts "======="
#     task_group.each do |task|
#       puts task.title
#       puts '---'
#       puts task.tags.map {|tag| tag.title}.join(',')
#       puts "\n\n\n"
#     end
#   end
#   puts "\n\n"
# end

# importance_sorted_task_groups.each do |task|
#   puts "\n\n===Task==="
#   puts task.title
#   puts '----'
#   puts task.tags.map {|tag| tag.title}.join(',')
# end


def todays_tasks_as_json(tasks)
  todays_tasks = []
  combined_duration = 0

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

  todays_tasks
end


def gist_content
  tasks = db_tasks
  tasks = group_by_task_type(tasks).flatten
  tasks = time_groups(tasks)
  tasks = task_importance_sorted_time_groups(tasks)
  tasks = importance_sorted_task_groups(tasks)

  tasks.each do |time_group|
    puts "\n::::IMP. Sorted TIME GROUP::::"
    puts "======="
    time_group.each do |task_group|
      puts "\n::::task group::::"
      puts "======="
      task_group.each do |task|
        puts task.title
        puts '---'
        puts task.tags.map {|tag| tag.title}.join(',')
        puts "\n\n\n"
      end
    end
    puts "\n\n"
  end

  tasks = tasks.flatten
  tasks = sorted3_order(tasks)
  todays_tasks_as_json(tasks).join(',')
end

def push_to_gist
  client = Octokit::Client.new(:access_token => GITHUB_THINGS_TOKEN)

  client.edit_gist(GIST_ID, {
    files: {"todays_tasks.json" => {content: "[#{output}]"}}
  })
end

gist_content

# if $0 == __FILE__
#   raise ArgumentError, "Usage: #{$0} xh ym" unless ARGV.length > 0
#   puts output(ARGV.join(' '))
# end
