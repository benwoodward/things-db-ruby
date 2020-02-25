class Today
  attr_accessor :tasks
  def initialize(tasks, times_of_day_tags)
    @times_of_day_tags = times_of_day_tags
    @times_of_day = times_of_day_tags.keys
    @tasks = tasks
    @sorter = Sorter.new(@task_categories)
  end

  def tasks
    @tasks ||= todays_tasks
  end

  def todays_tasks
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
    TimeGroup.new(tasks)
  end

  def time_groups
    create_time_groups
  end

  def sort_and_print
    @sorter.sort_tasks(time_groups)
  end
end
