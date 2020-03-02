class MarkdownRenderer
  def initialize
    @task_group_markdown = ''
  end

  def render(group)
    if group.has_tasks?
      if group.has_groups?
        @task_group_markdown += "\n\n## #{group.heading}\n"
        group.groups.each do |_, group|
          render(group)
        end
      else
        task_group_content(group)
      end
    end
    @task_group_markdown
  end

  def task_group_content(group)
    if group.has_tasks?
      @task_group_markdown += "\n### #{group.heading}\n"
      group.tasks.each do |task|
        @task_group_markdown += "- [ ] [#{task.title}](#{task.things_url})\n"
      end
    end
  end
end
