class SortedTaskGroup
  def initialize(opts = {})
    @tasks = opts[:tasks]
    @type  = opts[:type]
  end

  def has_tasks?
    !@tasks.empty?
  end

  def title
    @type
  end

  def tasks
    @tasks
  end
end

