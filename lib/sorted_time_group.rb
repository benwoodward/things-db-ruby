class SortedTimeGroup
  def initialize(opts = {})
    @tasks = opts[:tasks]
    @task_categories = opts[:task_categories]
  end

  def tasks
    @tasks
  end

  def create_task_groups
    h = Hash.new
    @task_categories.each do |tag|
      h[tag.to_sym] = create_time_group(tasks: grouped_by_time_of_day[tag.to_sym])
    end
    h
  end

  def create_task_group(tasks:)
    SortedTaskGroup.new(tasks: tasks)
  end

  def grouped_by_task_type
    Grouper.new(tasks, @task_categories, catch_all: :other).group_by_tagging_categories
  end
end
