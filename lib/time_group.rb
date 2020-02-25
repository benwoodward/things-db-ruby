class TimeGroup
  def initialize(opts = {})
    @tasks = opts[:tasks]
    @task_categories = opts[:task_categories]
  end

  def tasks
    @tasks
  end

  def grouped_by_task_type
    Grouper.new(tasks, @task_categories, catch_all: :other).group_by_tagging_categories
  end
end
