class Today
  attr_reader :tasks, :groups
  def initialize(opts = {})
    @task_categories   = opts[:task_categories]
    @times_of_day      = opts[:times_of_day]
    @tasks             = opts[:tasks]
  end

  def heading
    Date.today.strftime("%A %B %d, %Y")
  end

  def print_heading
    puts "------------------------------------------"
    puts "|         #{heading}       |"
    puts "------------------------------------------"
  end

  def has_tasks?
    groups.values.select {|time_group| time_group.has_tasks? }.count > 0
  end

  def has_groups?
    !groups.empty?
  end

  def tasks
    @tasks ||= database_tasks
  end

  def groups
    @groups ||= create_groups
  end

  def create_groups
    h = Hash.new
    @times_of_day.keys.each do |time_of_day|
      h[time_of_day.to_sym] = create_group(tasks: grouped_by_time_of_day[time_of_day.to_sym], time_of_day: time_of_day)
    end
    h
  end

  def create_group(tasks:, time_of_day:)
    SortedTimeGroup.new(tasks: tasks, task_categories: @task_categories, time_of_day: time_of_day)
  end

  def grouped_by_time_of_day
    Grouper.new(tasks, @times_of_day, catch_all: :anytime).group_by_tagging_categories
  end

  def database_tasks
    Queries.todays_tasks
  end

  def sorted_tasks
    groups
  end
end
