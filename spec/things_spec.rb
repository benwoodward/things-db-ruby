require 'spec_helper'
require 'json'

describe Sorter do
  describe '#arranged_tasks' do
    xit 'should be an array of Task objects' do
      tasks = described_class.arranged_tasks
      expect(tasks).to be_an(Array)
      expect(tasks.first).to be_an_instance_of(Task)
    end
  end

  describe '#group_by_task_type' do
    it 'groups tasks by type' do
      chore_tag = double(title: 'what:chore')
      errand_tag = double(title: 'what:errand')
      phonecall_tag = double(title: 'what:phonecall')
      message_tag = double(title: 'what:message')
      email_tag = double(title: 'what:email')
      other_tag = double(title: 'what:nonexistenttag')

      chore1 = double(title: 'chore1', tags: [chore_tag])
      chore2 = double(title: 'chore2', tags: [chore_tag])
      errand1 = double(title: 'errand1', tags: [errand_tag])
      errand2 = double(title: 'errand2', tags: [errand_tag])
      phonecall = double(title: 'phonecall', tags: [phonecall_tag])
      message = double(title: 'message', tags: [message_tag])
      email = double(title: 'email', tags: [email_tag])
      other = double(title: 'other', tags: [other_tag])

      grouped_tasks = described_class.group_by_task_type([
        chore1,
        message,
        errand1,
        other,
        email,
        chore2,
        phonecall,
        errand2
      ])

      expect(grouped_tasks[:chores][0].title).to eq('chore1')
      expect(grouped_tasks[:chores][1].title).to eq('chore2')
      expect(grouped_tasks[:other][0].title).to eq('other')
      expect(grouped_tasks[:errands][0].title).to eq('errand1')
      expect(grouped_tasks[:errands][1].title).to eq('errand2')
      expect(grouped_tasks[:admin][0].title).to eq('message').or eq('email').or eq('phonecall')
      expect(grouped_tasks[:admin][1].title).to eq('message').or eq('email').or eq('phonecall')
      expect(grouped_tasks[:admin][2].title).to eq('message').or eq('email').or eq('phonecall')
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

      expect(grouped_tasks[:first_thing][0].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[:first_thing][1].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[:morning][0].title).to eq('morning_task1').or eq('morning_task2')
      expect(grouped_tasks[:morning][1].title).to eq('morning_task1').or eq('morning_task2')
      expect(grouped_tasks[:anytime][0].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(grouped_tasks[:anytime][1].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(grouped_tasks[:afternoon][0].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(grouped_tasks[:afternoon][1].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(grouped_tasks[:evening][0].title).to eq('evening_task1').or eq('evening_task2')
      expect(grouped_tasks[:evening][1].title).to eq('evening_task1').or eq('evening_task2')
    end
  end

  describe '#time_groups' do
    it 'groups by time of day' do
      # when: tags
      first_thing_tag = double(title: 'when:first-thing')
      morning_tag = double(title: 'when:morning')
      afternoon_tag = double(title: 'when:afternoon')
      evening_tag = double(title: 'when:evening')
      anytime_tag = double(title: 'ojefoijvljfjk')

      # tasks
      first_thing_task1 = double(title: 'first_thing_task1', tags: [first_thing_tag])
      first_thing_task2 = double(title: 'first_thing_task2', tags: [first_thing_tag])
      evening_task1 = double(title: 'evening_task1', tags: [evening_tag])
      evening_task2 = double(title: 'evening_task2', tags: [evening_tag])

      grouped_tasks = described_class.time_groups([
        evening_task1,
        first_thing_task1,
        evening_task2,
        first_thing_task2,
      ])

      expect(grouped_tasks[:first_thing][0].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[:first_thing][1].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(grouped_tasks[:evening][0].title).to eq('evening_task1').or eq('evening_task2')
      expect(grouped_tasks[:evening][1].title).to eq('evening_task1').or eq('evening_task2')
    end
  end

  describe '#urgency_sorted_time_groups' do
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
      asap_urgency_tag = double(title: 'urg:asap')

      # TASKS
      # -----
      # research
      low_urgency_research     = double(title: 'low_urg, research',  tags: [low_urgency_tag, research_tag])
      medium_urgency_research  = double(title: 'med_urg, research',  tags: [medium_urgency_tag, research_tag])
      high_urgency_research    = double(title: 'high_urg, research', tags: [high_urgency_tag, research_tag])
      asap_urgency_research = double(title: 'asap_urg, research',  tags: [asap_urgency_tag, research_tag])

      # chores
      low_urgency_chore     = double(title: 'low_urg, chore',  tags: [low_urgency_tag, chore_tag])
      medium_urgency_chore  = double(title: 'med_urg, chore',  tags: [medium_urgency_tag, chore_tag])
      high_urgency_chore    = double(title: 'high_urg, chore', tags: [high_urgency_tag, chore_tag])
      asap_urgency_chore = double(title: 'asap_urg, chore',  tags: [asap_urgency_tag, chore_tag])

      # admin tasks
      low_urgency_admin     = double(title: 'low_urg, admin',  tags: [low_urgency_tag, admin_tag])
      medium_urgency_admin  = double(title: 'med_urg, admin',  tags: [medium_urgency_tag, admin_tag])
      high_urgency_admin    = double(title: 'high_urg, admin', tags: [high_urgency_tag, admin_tag])
      asap_urgency_admin = double(title: 'asap_urg, admin',  tags: [asap_urgency_tag, admin_tag])

      # downtime tasks
      low_urgency_downtime     = double(title: 'low_urg, downtime',  tags: [low_urgency_tag, downtime_tag])
      medium_urgency_downtime  = double(title: 'med_urg, downtime',  tags: [medium_urgency_tag, downtime_tag])
      high_urgency_downtime    = double(title: 'high_urg, downtime', tags: [high_urgency_tag, downtime_tag])
      asap_urgency_downtime = double(title: 'asap_urg, downtime',  tags: [asap_urgency_tag, downtime_tag])

      sorted_time_groups = described_class.urgency_sorted_time_groups(
        [
          # a time group, e.g. first thing
          [
            # downtime
            [
              low_urgency_downtime, high_urgency_downtime, asap_urgency_downtime, medium_urgency_downtime
            ],
            # chores
            [
              medium_urgency_chore, asap_urgency_chore, low_urgency_chore, high_urgency_chore,
            ]
          ],

          # a time group, e.g. afternoon
          [
            # admin tasks
            [
              medium_urgency_admin, asap_urgency_admin, low_urgency_admin, high_urgency_admin,
            ],

            # research
            [
              low_urgency_research, high_urgency_research, asap_urgency_research, medium_urgency_research
            ],

            # chores
            [
              medium_urgency_chore, asap_urgency_chore, low_urgency_chore, high_urgency_chore,
            ]
          ]
        ]
      )

      # TIME GROUP 1 / Downtime tasks
      expect(sorted_time_groups[0][0][0].title).to eq('asap_urg, downtime')
      expect(sorted_time_groups[0][0][1].title).to eq('high_urg, downtime')
      expect(sorted_time_groups[0][0][2].title).to eq('med_urg, downtime')
      expect(sorted_time_groups[0][0][3].title).to eq('low_urg, downtime')

      # TIME GROUP 1 / Chores
      expect(sorted_time_groups[0][1][0].title).to eq('asap_urg, chore')
      expect(sorted_time_groups[0][1][1].title).to eq('high_urg, chore')
      expect(sorted_time_groups[0][1][2].title).to eq('med_urg, chore')
      expect(sorted_time_groups[0][1][3].title).to eq('low_urg, chore')

      # TIME GROUP 2 / Admin tasks
      expect(sorted_time_groups[1][0][0].title).to eq('asap_urg, admin')
      expect(sorted_time_groups[1][0][1].title).to eq('high_urg, admin')
      expect(sorted_time_groups[1][0][2].title).to eq('med_urg, admin')
      expect(sorted_time_groups[1][0][3].title).to eq('low_urg, admin')

      # TIME GROUP 2 / Research
      expect(sorted_time_groups[1][1][0].title).to eq('asap_urg, research')
      expect(sorted_time_groups[1][1][1].title).to eq('high_urg, research')
      expect(sorted_time_groups[1][1][2].title).to eq('med_urg, research')
      expect(sorted_time_groups[1][1][3].title).to eq('low_urg, research')

     # TIME GROUP 2 / Chores
      expect(sorted_time_groups[1][2][0].title).to eq('asap_urg, chore')
      expect(sorted_time_groups[1][2][1].title).to eq('high_urg, chore')
      expect(sorted_time_groups[1][2][2].title).to eq('med_urg, chore')
      expect(sorted_time_groups[1][2][3].title).to eq('low_urg, chore')
    end
  end

  describe '#sort_task_group_by_urgency' do
    it 'sorts a group of tasks by urgency' do
      low_urgency_tag     = double(title: 'urg:low')
      medium_urgency_tag  = double(title: 'urg:medium')
      high_urgency_tag    = double(title: 'urg:high')
      asap_urgency_tag = double(title: 'urg:asap')

      low_urgency_task     = double(title: 'low_urgency_task',     tags: [low_urgency_tag])
      medium_urgency_task  = double(title: 'medium_urgency_task',  tags: [medium_urgency_tag])
      high_urgency_task    = double(title: 'high_urgency_task',    tags: [high_urgency_tag])
      asap_urgency_task = double(title: 'asap_urgency_task', tags: [asap_urgency_tag])

      sorted_tasks = described_class.sort_task_group_by_urgency([
        high_urgency_task,
        low_urgency_task,
        asap_urgency_task,
        medium_urgency_task,
      ])

      expect(sorted_tasks[0].title).to eq('asap_urgency_task')
      expect(sorted_tasks[1].title).to eq('high_urgency_task')
      expect(sorted_tasks[2].title).to eq('medium_urgency_task')
      expect(sorted_tasks[3].title).to eq('low_urgency_task')
    end
  end

  describe '#urgency_sorted_task_groups' do
    it 'ranks and sorts (nested) groups of tasks based on their highest rated task for a given group' do
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
      asap_urgency_tag = double(title: 'urg:asap')

      # TASKS
      # -----
      # research
      low_urgency_research     = double(title: 'low_urg, research',  tags: [low_urgency_tag, research_tag])
      medium_urgency_research  = double(title: 'med_urg, research',  tags: [medium_urgency_tag, research_tag])
      high_urgency_research    = double(title: 'high_urg, research', tags: [high_urgency_tag, research_tag])
      asap_urgency_research = double(title: 'asap_urg, research',  tags: [asap_urgency_tag, research_tag])

      # chores
      low_urgency_chore     = double(title: 'low_urg, chore',  tags: [low_urgency_tag, chore_tag])
      medium_urgency_chore  = double(title: 'med_urg, chore',  tags: [medium_urgency_tag, chore_tag])
      high_urgency_chore    = double(title: 'high_urg, chore', tags: [high_urgency_tag, chore_tag])
      asap_urgency_chore = double(title: 'asap_urg, chore',  tags: [asap_urgency_tag, chore_tag])

      # admin tasks
      low_urgency_admin     = double(title: 'low_urg, admin',  tags: [low_urgency_tag, admin_tag])
      medium_urgency_admin  = double(title: 'med_urg, admin',  tags: [medium_urgency_tag, admin_tag])
      high_urgency_admin    = double(title: 'high_urg, admin', tags: [high_urgency_tag, admin_tag])
      asap_urgency_admin = double(title: 'asap_urg, admin',  tags: [asap_urgency_tag, admin_tag])

      # downtime tasks
      low_urgency_downtime     = double(title: 'low_urg, downtime',  tags: [low_urgency_tag, downtime_tag])
      medium_urgency_downtime  = double(title: 'med_urg, downtime',  tags: [medium_urgency_tag, downtime_tag])
      high_urgency_downtime    = double(title: 'high_urg, downtime', tags: [high_urgency_tag, downtime_tag])
      asap_urgency_downtime = double(title: 'asap_urg, downtime',  tags: [asap_urgency_tag, downtime_tag])

      sorted_time_groups = described_class.urgency_sorted_task_groups(
        [
          # a time group, e.g. first thing
          [
            # a task group, e.g. research
            [
              low_urgency_research, low_urgency_research
            ],
            # a task group, e.g. downtime
            [
              medium_urgency_downtime, low_urgency_downtime, low_urgency_downtime
            ],
            # a task group, e.g. chores
            [
              high_urgency_chore, medium_urgency_chore, low_urgency_chore
            ],
            # a task group, e.g. admin
            [
              asap_urgency_admin, medium_urgency_admin, low_urgency_admin, high_urgency_admin
            ]
          ],
          # a time group, e.g. first thing
          [
            # a task group, e.g. research
            [
              low_urgency_admin, low_urgency_admin
            ],
            # a task group, e.g. downtime
            [
              medium_urgency_chore, low_urgency_chore, low_urgency_chore
            ],
            # a task group, e.g. chores
            [
              high_urgency_research, medium_urgency_research, low_urgency_research
            ],
            # a task group, e.g. admin
            [
              asap_urgency_downtime, medium_urgency_downtime, low_urgency_downtime, high_urgency_downtime
            ]
          ]
        ]
      )

      # TIME GROUP 1 / Chores
      expect(sorted_time_groups[0][0][0].title).to eq('asap_urg, admin')
      expect(sorted_time_groups[0][1][0].title).to eq('high_urg, chore')
      expect(sorted_time_groups[0][2][0].title).to eq('med_urg, downtime')
      expect(sorted_time_groups[0][3][0].title).to eq('low_urg, research')

      # TIME GROUP 1 / Downtime tasks
      expect(sorted_time_groups[1][0][0].title).to eq('asap_urg, downtime')
      expect(sorted_time_groups[1][1][0].title).to eq('high_urg, research')
      expect(sorted_time_groups[1][2][0].title).to eq('med_urg, chore')
      expect(sorted_time_groups[1][3][0].title).to eq('low_urg, admin')

      # TIME GROUP 2 / Admin tasks
      # expect(sorted_time_groups[1][0][0].title).to eq('asap_urg, admin')
      # expect(sorted_time_groups[1][0][1].title).to eq('high_urg, admin')
      # expect(sorted_time_groups[1][0][2].title).to eq('med_urg, admin')
      # expect(sorted_time_groups[1][0][3].title).to eq('low_urg, admin')

      # TIME GROUP 2 / Research
      # expect(sorted_time_groups[1][1][0].title).to eq('asap_urg, research')
      # expect(sorted_time_groups[1][1][1].title).to eq('high_urg, research')
      # expect(sorted_time_groups[1][1][2].title).to eq('med_urg, research')
      # expect(sorted_time_groups[1][1][3].title).to eq('low_urg, research')

      # TIME GROUP 2 / Chores
      # expect(sorted_time_groups[1][2][0].title).to eq('asap_urg, chore')
      # expect(sorted_time_groups[1][2][1].title).to eq('high_urg, chore')
      # expect(sorted_time_groups[1][2][2].title).to eq('med_urg, chore')
      # expect(sorted_time_groups[1][2][3].title).to eq('low_urg, chore')
    end
  end
end
