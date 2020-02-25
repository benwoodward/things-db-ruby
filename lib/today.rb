class Today
  attr_accessor :tasks, :time_groups
  def initialize(opts = {})
    @times_of_day_tags = opts[:times_of_day_tags]
    @times_of_day      = opts[:times_of_day_tags].keys
    @tasks             = opts[:tasks]
  end

  def sorted_tasks
    time_groups
  end

  def sorter
    Sorter.new(tasks)
  end

  def tasks
    @tasks ||= database_tasks
  end

  def database_tasks
    Queries.todays_tasks
  end

  def grouped_by_time_of_day
    Grouper.new(tasks, @times_of_day_tags, catch_all: :anytime).group_by_tagging_categories
  end

  def create_time_groups
    h = Hash.new
    @times_of_day.each do |tag|
      h[tag.to_sym] = create_time_group(tasks: grouped_by_time_of_day[tag.to_sym])
    end
    h
  end

  def create_time_group(tasks:)
    TimeGroup.new(tasks: tasks)
  end

  def time_groups
    @time_groups ||= create_time_groups
  end
end
