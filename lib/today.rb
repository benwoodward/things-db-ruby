class Today
  attr_accessor :tasks, :time_groups
  def initialize(opts = {})
    @task_categories   = opts[:task_categories]
    @times_of_day      = opts[:times_of_day]
    @tasks             = opts[:tasks]
  end

  def sorted_tasks
    time_groups
  end

  def tasks
    @tasks ||= database_tasks
  end

  def database_tasks
    Queries.todays_tasks
  end

  def grouped_by_time_of_day
    Grouper.new(tasks, @times_of_day, catch_all: :anytime).group_by_tagging_categories
  end

  def create_time_groups
    h = Hash.new
    @times_of_day.keys.each do |time_of_day|
      h[time_of_day.to_sym] = create_time_group(tasks: grouped_by_time_of_day[time_of_day.to_sym], time_of_day: time_of_day)
    end
    h
  end

  def create_time_group(tasks:, time_of_day:)
    SortedTimeGroup.new(tasks: tasks, task_categories: @task_categories, time_of_day: time_of_day)
  end

  def time_groups
    @time_groups ||= create_time_groups
  end
end
