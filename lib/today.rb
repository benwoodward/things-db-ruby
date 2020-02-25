class Today
  def initialize(times_of_day_tags)
    @times_of_day_tags = times_of_day_tags
    @times_of_day = times_of_day_tags.keys
    @sorter = Sorter.new(@task_categories)
  end

  def todays_tasks
    Queries.todays_tasks
  end

  def group_by_time_of_day(tasks)
    Grouper.new(tasks, @times_of_day_tags, catch_all: :anytime).group_by_tagging_categories
  end

  def create_time_groups_from_tasks(tasks, tags_to_group_by)
    groupings = group_by_time_of_day(tasks)

    h = Hash.new

    tags_to_group_by.each do |tag|
      h[tag.to_sym] = create_time_group(tasks: groupings[tag.to_sym])
    end

    h
  end

  def create_time_group(tasks:)
    TimeGroup.new(tasks)
  end

  def time_groups(tasks = todays_tasks)
    create_time_groups_from_tasks(tasks, @times_of_day)
  end

  def sort_and_print
    @sorter.sort_tasks(time_groups)
  end
end
