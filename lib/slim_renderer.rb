class SlimRenderer
  def initialize
    @layout = Tilt.new("lib/templates/layout.slim")
    @task_group = Tilt.new("lib/templates/task_group.slim")
    @task_group_html = ''
  end

  def render(group)
    render_task_group(group)
    @layout.render do
      @task_group_html
    end
  end

  def render_task_group(group)
    if group.has_tasks?
      if group.has_groups?
        @task_group_html += "<h2>#{group.heading}</h2>"
        group.groups.each do |_, group|
          render_task_group(group)
        end
      else
        @task_group_html += @task_group.render(group)
      end
    end
  end
end
