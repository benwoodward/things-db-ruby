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
      h[tag.to_sym] = groupings[tag.to_sym]
    end

    h
  end

  def todays_tasks_grouped_by_time_of_day
    create_time_groups_from_tasks(todays_tasks, @times_of_day)
  end

  def sort_and_print
    @sorter.sort_tasks(todays_tasks)
    # sorted_time_groups = urgency_sorted_time_groups(todays_tasks_grouped_by_time_of_day)
    # tasks = urgency_sorted_task_groups(sorted_time_groups)

    # Logger.print_task_list(tasks)
    # tasks.flatten
  end

end
