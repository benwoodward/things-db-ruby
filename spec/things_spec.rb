require 'spec_helper'
require 'json'

describe Sorter do
  describe '#arranged_tasks' do
    it 'should be an array of Task objects' do
      tasks = described_class.arranged_tasks
      expect(tasks).to be_an(Array)
      expect(tasks.first).to be_an_instance_of(Task)
    end
  end

  describe '#group_by_task_type' do
    it 'groups tasks by type' do
      chore_tag = double(title: 'what:chore')
      errand_tag = double(title: 'what:errand')
      chore1 = double(title: 'chore1', tags: [chore_tag])
      chore2 = double(title: 'chore2', tags: [chore_tag])
      errand1 = double(title: 'errand1', tags: [errand_tag])
      errand2 = double(title: 'errand2', tags: [errand_tag])

      grouped_tasks = described_class.group_by_task_type([
        chore1,
        errand1,
        chore2,
        errand2
      ])

      expect(grouped_tasks[0][0].title).to eq('chore1')
      expect(grouped_tasks[0][1].title).to eq('chore2')
      expect(grouped_tasks[1][0].title).to eq('errand1')
      expect(grouped_tasks[1][1].title).to eq('errand2')

      expect(grouped_tasks[0][0].tags.first.title).to eq('what:chore')
      expect(grouped_tasks[0][1].tags.first.title).to eq('what:chore')
      expect(grouped_tasks[1][0].tags.first.title).to eq('what:errand')
      expect(grouped_tasks[1][1].tags.first.title).to eq('what:errand')
    end
  end

  describe '#group_by_time_of_day' do
    it 'groups tasks by time of day tags' do
      first_thing_tag = double(title: 'when:first-thing')
      morning_tag = double(title: 'when:morning')
      afternoon_tag = double(title: 'when:afternoon')
      evening_tag = double(title: 'when:evening')
      anytime_tag = double(title: 'ojefoijvljfjk')

      first_thing_task1 = double(title: 'first_thing_task1', tags: [first_thing_tag])
      first_thing_task2 = double(title: 'first_thing_task2', tags: [first_thing_tag])
      morning_task1 = double(title: 'morning_task1', tags: [morning_tag])
      morning_task2 = double(title: 'morning_task2', tags: [morning_tag])
      afternoon_task1 = double(title: 'afternoon_task1', tags: [afternoon_tag])
      afternoon_task2 = double(title: 'afternoon_task2', tags: [afternoon_tag])
      evening_task1 = double(title: 'evening_task1', tags: [evening_tag])
      evening_task2 = double(title: 'evening_task2', tags: [evening_tag])
      anytime_task1 = double(title: 'anytime_task1', tags: [anytime_tag])
      anytime_task2 = double(title: 'anytime_task2', tags: [anytime_tag])

      grouped_tasks = described_class.group_by_time_of_day([
        morning_task1,
        evening_task1,
        morning_task2,
        anytime_task1,
        first_thing_task1,
        afternoon_task1,
        evening_task2,
        first_thing_task2,
        afternoon_task2,
        anytime_task2,
      ])

      expect(grouped_tasks[0][0].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[0][1].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[1][0].title).to eq('morning_task1').or eq('morning_task2')
      expect(grouped_tasks[1][1].title).to eq('morning_task1').or eq('morning_task2')
      expect(grouped_tasks[2][0].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(grouped_tasks[2][1].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(grouped_tasks[3][0].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(grouped_tasks[3][1].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(grouped_tasks[4][0].title).to eq('evening_task1').or eq('evening_task2')
      expect(grouped_tasks[4][1].title).to eq('evening_task1').or eq('evening_task2')
    end
  end

  describe '#time_groups' do
    it 'groups by time of day, then subgroups by task type' do
      # when: tags
      first_thing_tag = double(title: 'when:first-thing')
      morning_tag = double(title: 'when:morning')
      afternoon_tag = double(title: 'when:afternoon')
      evening_tag = double(title: 'when:evening')
      anytime_tag = double(title: 'ojefoijvljfjk')

      # what: tags
      chore_tag = double(title: 'what:chore')
      errand_tag = double(title: 'what:errand')
      shopping_list_tag = double(title: 'what:shopping-trip')
      appointment_tag = double(title: 'what:appointment')
      phonecall_tag = double(title: 'what:phonecall')
      email_tag = double(title: 'what:email')
      message_tag = double(title: 'what:message')
      focussed_work_tag = double(title: 'what:focussed-work')
      code_tag = double(title: 'what:code')
      research_tag = double(title: 'what:research')
      downtime_tag = double(title: 'what:downtime')
      to_watch_tag = double(title: 'what:to-watch')
      to_read_tag = double(title: 'what:to-read')

      # what:research tasks
      first_thing_research_task1 = double(title: 'first_thing_research_task1', tags: [first_thing_tag, research_tag])
      first_thing_research_task2 = double(title: 'first_thing_research_task2', tags: [first_thing_tag, research_tag])
      evening_research_task1 = double(title: 'evening_research_task1', tags: [evening_tag, research_tag])
      evening_research_task2 = double(title: 'evening_research_task2', tags: [evening_tag, research_tag])

      # what:chore tasks
      first_thing_chore_task1 = double(title: 'first_thing_chore_task1', tags: [first_thing_tag, chore_tag])
      first_thing_chore_task2 = double(title: 'first_thing_chore_task2', tags: [first_thing_tag, chore_tag])
      evening_chore_task1 = double(title: 'evening_chore_task1', tags: [evening_tag, chore_tag])
      evening_chore_task2 = double(title: 'evening_chore_task2', tags: [evening_tag, chore_tag])

      grouped_tasks = described_class.time_groups([
        evening_research_task1,
        first_thing_research_task2,
        evening_research_task2,
        evening_chore_task2,
        first_thing_chore_task2,
        evening_chore_task1,
        first_thing_research_task1,
        first_thing_chore_task1,
      ])

      expect(grouped_tasks[0][0][0].title).to eq('first_thing_chore_task1').or eq('first_thing_chore_task2')
      expect(grouped_tasks[0][0][1].title).to eq('first_thing_chore_task2').or eq('first_thing_chore_task1')
      expect(grouped_tasks[0][1][0].title).to eq('first_thing_research_task1').or eq('first_thing_research_task2')
      expect(grouped_tasks[0][1][1].title).to eq('first_thing_research_task2').or eq('first_thing_research_task1')
      expect(grouped_tasks[-1][0][0].title).to eq('evening_chore_task1').or eq('evening_chore_task2')
      expect(grouped_tasks[-1][0][1].title).to eq('evening_chore_task2').or eq('evening_chore_task1')
      expect(grouped_tasks[-1][1][0].title).to eq('evening_research_task1').or eq('evening_research_task2')
      expect(grouped_tasks[-1][1][1].title).to eq('evening_research_task2').or eq('evening_research_task1')
    end
  end

  describe '#task_importance_sorted_time_groups' do
    it 'sorts double-nested groups of tasks by urgency tags' do
      # TAGS
      # -----
      # what: tags
      chore_tag         = double(title: 'what:chore')
      admin_tag         = double(title: 'what:admin')
      downtime_tag      = double(title: 'what:downtime')
      research_tag      = double(title: 'what:research')

      # urg: tags
      low_urgency_tag     = double(title: 'urg:low')
      medium_urgency_tag  = double(title: 'urg:medium')
      high_urgency_tag    = double(title: 'urg:high')
      extreme_urgency_tag = double(title: 'urg:extreme')

      # TASKS
      # -----
      # research
      low_urgency_research     = double(title: 'low_urg, research',  tags: [low_urgency_tag, research_tag])
      medium_urgency_research  = double(title: 'med_urg, research',  tags: [medium_urgency_tag, research_tag])
      high_urgency_research    = double(title: 'high_urg, research', tags: [high_urgency_tag, research_tag])
      extreme_urgency_research = double(title: 'ext_urg, research',  tags: [extreme_urgency_tag, research_tag])

      # chores
      low_urgency_chore     = double(title: 'low_urg, chore',  tags: [low_urgency_tag, chore_tag])
      medium_urgency_chore  = double(title: 'med_urg, chore',  tags: [medium_urgency_tag, chore_tag])
      high_urgency_chore    = double(title: 'high_urg, chore', tags: [high_urgency_tag, chore_tag])
      extreme_urgency_chore = double(title: 'ext_urg, chore',  tags: [extreme_urgency_tag, chore_tag])

      # admin tasks
      low_urgency_admin     = double(title: 'low_urg, admin',  tags: [low_urgency_tag, admin_tag])
      medium_urgency_admin  = double(title: 'med_urg, admin',  tags: [medium_urgency_tag, admin_tag])
      high_urgency_admin    = double(title: 'high_urg, admin', tags: [high_urgency_tag, admin_tag])
      extreme_urgency_admin = double(title: 'ext_urg, admin',  tags: [extreme_urgency_tag, admin_tag])

      # downtime tasks
      low_urgency_downtime     = double(title: 'low_urg, downtime',  tags: [low_urgency_tag, downtime_tag])
      medium_urgency_downtime  = double(title: 'med_urg, downtime',  tags: [medium_urgency_tag, downtime_tag])
      high_urgency_downtime    = double(title: 'high_urg, downtime', tags: [high_urgency_tag, downtime_tag])
      extreme_urgency_downtime = double(title: 'ext_urg, downtime',  tags: [extreme_urgency_tag, downtime_tag])

      sorted_time_groups = described_class.task_importance_sorted_time_groups(
        [
          # a time group, e.g. first thing
          [
            # downtime
            [
              low_urgency_downtime, high_urgency_downtime, extreme_urgency_downtime, medium_urgency_downtime
            ],
            # chores
            [
              medium_urgency_chore, extreme_urgency_chore, low_urgency_chore, high_urgency_chore,
            ]
          ],

          # a time group, e.g. afternoon
          [
            # admin tasks
            [
              medium_urgency_admin, extreme_urgency_admin, low_urgency_admin, high_urgency_admin,
            ],

            # research
            [
              low_urgency_research, high_urgency_research, extreme_urgency_research, medium_urgency_research
            ],

            # chores
            [
              medium_urgency_chore, extreme_urgency_chore, low_urgency_chore, high_urgency_chore,
            ]
          ]
        ]
      )

      # TIME GROUP 1 / Downtime tasks
      expect(sorted_time_groups[0][0][0].title).to eq('ext_urg, downtime')
      expect(sorted_time_groups[0][0][1].title).to eq('high_urg, downtime')
      expect(sorted_time_groups[0][0][2].title).to eq('med_urg, downtime')
      expect(sorted_time_groups[0][0][3].title).to eq('low_urg, downtime')

      # TIME GROUP 1 / Chores
      expect(sorted_time_groups[0][1][0].title).to eq('ext_urg, chore')
      expect(sorted_time_groups[0][1][1].title).to eq('high_urg, chore')
      expect(sorted_time_groups[0][1][2].title).to eq('med_urg, chore')
      expect(sorted_time_groups[0][1][3].title).to eq('low_urg, chore')

      # TIME GROUP 2 / Admin tasks
      expect(sorted_time_groups[1][0][0].title).to eq('ext_urg, admin')
      expect(sorted_time_groups[1][0][1].title).to eq('high_urg, admin')
      expect(sorted_time_groups[1][0][2].title).to eq('med_urg, admin')
      expect(sorted_time_groups[1][0][3].title).to eq('low_urg, admin')

      # TIME GROUP 2 / Research
      expect(sorted_time_groups[1][1][0].title).to eq('ext_urg, research')
      expect(sorted_time_groups[1][1][1].title).to eq('high_urg, research')
      expect(sorted_time_groups[1][1][2].title).to eq('med_urg, research')
      expect(sorted_time_groups[1][1][3].title).to eq('low_urg, research')

     # TIME GROUP 2 / Chores
      expect(sorted_time_groups[1][2][0].title).to eq('ext_urg, chore')
      expect(sorted_time_groups[1][2][1].title).to eq('high_urg, chore')
      expect(sorted_time_groups[1][2][2].title).to eq('med_urg, chore')
      expect(sorted_time_groups[1][2][3].title).to eq('low_urg, chore')
    end
  end

  describe '#sort_task_group' do
    it 'sorts a group of tasks by urgency' do
      low_urgency_tag     = double(title: 'urg:low')
      medium_urgency_tag  = double(title: 'urg:medium')
      high_urgency_tag    = double(title: 'urg:high')
      extreme_urgency_tag = double(title: 'urg:extreme')

      low_urgency_task     = double(title: 'low_urgency_task',     tags: [low_urgency_tag])
      medium_urgency_task  = double(title: 'medium_urgency_task',  tags: [medium_urgency_tag])
      high_urgency_task    = double(title: 'high_urgency_task',    tags: [high_urgency_tag])
      extreme_urgency_task = double(title: 'extreme_urgency_task', tags: [extreme_urgency_tag])

      sorted_tasks = described_class.sort_task_group([
        high_urgency_task,
        low_urgency_task,
        extreme_urgency_task,
        medium_urgency_task,
      ])

      expect(sorted_tasks[0].title).to eq('extreme_urgency_task')
      expect(sorted_tasks[1].title).to eq('high_urgency_task')
      expect(sorted_tasks[2].title).to eq('medium_urgency_task')
      expect(sorted_tasks[3].title).to eq('low_urgency_task')
    end
  end

  describe '#importance_sorted_task_groups' do
  end
end
