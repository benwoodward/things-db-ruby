class Sorter
  class << self
    TIMES_OF_DAY = {
        first_thing: ['when:first-thing'],
        morning:     ['when:morning'],
        anytime:     nil,
        afternoon:   ['when:afternoon'],
        evening:     ['when:evening']
      }

    TASK_CATEGORIES = {
      chores:        ['what:chore'],
      focussed_work: ['what:focussed-work', 'what:code', 'what:research'],
      other:         nil,
      errands:       ['what:errand', 'what:shopping-trip', 'what:appointment'],
      admin:         ['what:admin', 'what:phonecall', 'what:email', 'what:message'],
      downtime:      ['what:downtime', 'what:to-watch', 'what:to-read']
    }

    def group_tasks(tasks, filter, catch_all:)
      Grouper.new(tasks, filter, catch_all).group_by_tagging_categories
    end

    def group_by_time_of_day(tasks)
      group_tasks(tasks, TIMES_OF_DAY, catch_all: :anytime)
    end

    def group_by_task_type(tasks)
      group_tasks(tasks, TASK_CATEGORIES, catch_all: :other)
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
        group_by_task_type(groupings[:first_thing]).values,
        group_by_task_type(groupings[:morning]).values,
        group_by_task_type(groupings[:anytime]).values,
        group_by_task_type(groupings[:afternoon]).values,
        group_by_task_type(groupings[:evening]).values
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

    def contains_specified_tags?(tags, tag_names)
      return false if tags.nil? or tag_names.nil?
      tags.select {|tag| tag_names.include?(tag.title) }.count > 0
    end

    def task_group_contains_tag?(task_group, tag_name)
      contains_specified_tags?(all_tags_in_group(task_group), [tag_name])
    end

    def all_tags_in_group(task_group)
      task_group.map {|task| task.tags}.flatten
    end

    def arranged_tasks
      time_groups = time_groups(Queries.todays_tasks)
      sorted_time_groups = task_importance_sorted_time_groups(time_groups)
      tasks = urgency_sorted_task_groups(sorted_time_groups)
      Logger.print_task_list(tasks)
      tasks.flatten
    end
  end
end
