class SortedTimeGroup
  attr_reader :tasks, :groups
  def initialize(opts = {})
    @tasks = opts[:tasks]
    @task_categories = opts[:task_categories]
    @time_of_day = opts[:time_of_day]
  end

  def heading
    @time_of_day
  end

  def print_heading
    puts ''
    puts "\e[32m*********\e[m"
    puts "\e[32m#{heading.upcase}\e[m"
    puts "\e[32m*********\e[m"
  end

  def has_tasks?
    groups.values.select {|task_group| task_group.has_tasks? }.count > 0
  end

  def has_groups?
    !groups.empty?
  end

  def tasks
    @tasks
  end

  def groups
    @task_groups ||= create_groups
  end

  def create_groups
    h = Hash.new
    @task_categories.keys.each do |task_type|
      h[task_type.to_sym] = create_group(tasks: grouped_by_task_type[task_type.to_sym], type: task_type)
    end
    h
  end

  def create_group(tasks:, type:)
    SortedTaskGroup.new(tasks: tasks, type: type)
  end

  def grouped_by_task_type
    Grouper.new(tasks, @task_categories, catch_all: :other).group_by_tagging_categories
  end
end
