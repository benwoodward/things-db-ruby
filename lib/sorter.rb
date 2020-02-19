class Sorter
  class << self
    def contains_specified_tags?(tags, tag_names)
      return false if tags.nil? or tag_names.nil?
      tags.select {|tag| tag_names.include?(tag.title) }.count > 0
    end

    def group_by_time_of_day(tasks)
      return [] if tasks.nil?
      groupings = Hash.new { |hash, key| hash[key] = [] }
      result = []

      tagging_groups = {
        first_thing: ['when:first-thing'],
        morning:     ['when:morning'],
        anytime:     nil,
        afternoon:   ['when:afternoon'],
        evening:     ['when:evening']
      }

      tasks.each do |task|
        tagging_groups.each do |category, tags|
          if !contains_specified_tags?(task.tags, tagging_groups.values.flatten)
            groupings[:anytime] << task
          elsif contains_specified_tags?(task.tags, tags)
            groupings[category] << task
          end
        end
      end

      groupings
    end

    def group_by_task_type(tasks)
      return [] if tasks.nil?
      groupings = Hash.new { |hash, key| hash[key] = [] }
      result = []

      tagging_groups = {
        chores:        ['what:chore'],
        focussed_work: ['what:focussed-work', 'what:code', 'what:research'],
        other:         nil,
        errands:       ['what:errand', 'what:shopping-trip', 'what:appointment'],
        admin:         ['what:admin', 'what:phonecall', 'what:email', 'what:message'],
        downtime:      ['what:downtime', 'what:to-watch', 'what:to-read']
      }

      tasks.each do |task|
        tagging_groups.each do |category, tags|
          if !contains_specified_tags?(task.tags, tagging_groups.values.flatten)
            groupings[:other] << task
          elsif contains_specified_tags?(task.tags, tags)
            groupings[category] << task
          end
        end
      end

      groupings[:admin] = group_by_admin_subgroup(groupings[:admin])

      tagging_groups.keys.each do |category|
        result << groupings[category] if !groupings[category].empty?
      end

      result
    end

    def group_by_admin_subgroup(tasks)
      general = []
      phonecalls = []
      messages = []
      emails = []

      tasks.each do |task|
        if contains_specified_tags?(task.tags, ['what:admin'])
          general << task
        elsif contains_specified_tags?(task.tags, ['what:phonecall'])
          phonecalls << task
        elsif contains_specified_tags?(task.tags, ['what:message'])
          messages << task
        elsif contains_specified_tags?(task.tags, ['what:email'])
          emails << task
        end
      end

      result = []

      [emails, messages, phonecalls, general].each do |grouping|
        result << grouping if !grouping.empty?
      end

      result.flatten
    end


    # {
    #   key: [[], []],
    #   key: [[], []]
    # }
    def time_groups(tasks)
      groupings = group_by_time_of_day(tasks)

      result = [
        group_by_task_type(groupings[:first_thing]),
        group_by_task_type(groupings[:morning]),
        group_by_task_type(groupings[:anytime]),
        group_by_task_type(groupings[:afternoon]),
        group_by_task_type(groupings[:evening])
      ]
    end

    def sort_task_group(task_group)
      ["urg:low", "urg:medium", "urg:high", "urg:asap"].inject(task_group) do |reordered_tasks, tag_name|
        reordered_tasks.partition do |task|
          contains_specified_tags?(task.tags, [tag_name])
        end.flatten
      end
    end

    def task_importance_sorted_time_groups(time_groupings)
      time_groupings.inject([]) do |updated_time_groups, time_group|
        updated_time_group = []
        time_group.each do |task_group|
          sorted_task_group = sort_task_group(task_group)
          updated_time_group << sorted_task_group
        end
        updated_time_groups << updated_time_group
      end
    end

    def urgency_sorted_task_groups(time_groups)
      time_groups.inject([]) do |sorted_time_groups, time_group|
        sorted_time_groups << sort_time_group_by_contains_urgency_tag(time_group)
      end
    end

    def sort_time_group_by_contains_urgency_tag(time_group)
      ["urg:low", "urg:medium", "urg:high", "urg:asap"].inject(time_group) do |task_groups, tag_name|
        sort_task_groups_by_group_contains_tag(task_groups, tag_name)
      end
    end

    def sort_task_groups_by_group_contains_tag(task_groups, tag_name)
      task_groups.each_with_index do |task_group, index|
        if task_group_contains_tag?(task_group, tag_name)
          task_groups.delete_at(index)
          task_groups.unshift task_group
        end
      end

      task_groups
    end

    def task_group_contains_tag?(task_group, tag_name)
      contains_specified_tags?(all_tags_in_group(task_group), [tag_name])
    end

    def all_tags_in_group(task_group)
      task_group.map {|task| task.tags}.flatten
    end

    def arranged_tasks
      grouped_tasks = group_by_task_type(Queries.todays_tasks).flatten
      time_groups = time_groups(grouped_tasks)
      sorted_time_groups = task_importance_sorted_time_groups(time_groups)
      tasks = urgency_sorted_task_groups(sorted_time_groups)
      Logger.print_task_list(tasks)
      tasks.flatten
    end
  end
end
