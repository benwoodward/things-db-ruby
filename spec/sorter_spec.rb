require 'spec_helper'
require 'json'

describe Sorter do
  before do
    @times_of_day_tags = {
      first_thing: ['when:first-thing'],
      morning:     ['when:morning'],
      anytime:     nil,
      afternoon:   ['when:afternoon'],
      evening:     ['when:evening']
    }

    @times_of_day = @times_of_day_tags.keys

    @task_categories = {
      chores:        ['what:chore'],
      focussed_work: ['what:focussed-work', 'what:code', 'what:research'],
      other:         nil,
      errands:       ['what:errand', 'what:shopping-trip', 'what:appointment'],
      admin:         ['what:admin', 'what:phonecall', 'what:email', 'what:message'],
      downtime:      ['what:downtime', 'what:to-watch', 'what:to-read']
    }
  end

  describe '#sort' do
    xit 'should be an array of Task objects' do
      tasks = described_class.new(@times_of_day_tags, @task_categories).sort
      expect(tasks).to be_an(Array)
      expect(tasks.first).to be_an_instance_of(Task)
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

      sorted_time_groups = described_class.new(@task_categories).urgency_sorted_time_groups(
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

      sorted_tasks = described_class.new(@task_categories).sort_task_group_by_urgency([
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

      sorted_time_groups = described_class.new(@task_categories).urgency_sorted_task_groups(
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
