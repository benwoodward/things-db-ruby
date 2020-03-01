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

  describe '#importance_sorted_time_groups' do
    xit 'sorts double-nested groups of tasks by importance tags' do
      # TAGS
      # -----
      # what: tags
      chore_tag         = double(title: 'what:chore')
      admin_tag         = double(title: 'what:admin')
      downtime_tag      = double(title: 'what:downtime')
      research_tag      = double(title: 'what:research')

      # imp: tags
      low_importance_tag     = double(title: 'imp:low')
      medium_importance_tag  = double(title: 'imp:medium')
      high_importance_tag    = double(title: 'imp:high')
      critical_importance_tag = double(title: 'imp:critical')

      # TASKS
      # -----
      # research
      low_importance_research     = double(title: 'low_importance, research',  tags: [low_importance_tag, research_tag])
      medium_importance_research  = double(title: 'med_importance, research',  tags: [medium_importance_tag, research_tag])
      high_importance_research    = double(title: 'high_importance, research', tags: [high_importance_tag, research_tag])
      critical_importance_research = double(title: 'critical_importance, research',  tags: [critical_importance_tag, research_tag])

      # chores
      low_importance_chore     = double(title: 'low_importance, chore',  tags: [low_importance_tag, chore_tag])
      medium_importance_chore  = double(title: 'med_importance, chore',  tags: [medium_importance_tag, chore_tag])
      high_importance_chore    = double(title: 'high_importance, chore', tags: [high_importance_tag, chore_tag])
      critical_importance_chore = double(title: 'critical_importance, chore',  tags: [critical_importance_tag, chore_tag])

      # admin tasks
      low_importance_admin     = double(title: 'low_importance, admin',  tags: [low_importance_tag, admin_tag])
      medium_importance_admin  = double(title: 'med_importance, admin',  tags: [medium_importance_tag, admin_tag])
      high_importance_admin    = double(title: 'high_importance, admin', tags: [high_importance_tag, admin_tag])
      critical_importance_admin = double(title: 'critical_importance, admin',  tags: [critical_importance_tag, admin_tag])

      # downtime tasks
      low_importance_downtime     = double(title: 'low_importance, downtime',  tags: [low_importance_tag, downtime_tag])
      medium_importance_downtime  = double(title: 'med_importance, downtime',  tags: [medium_importance_tag, downtime_tag])
      high_importance_downtime    = double(title: 'high_importance, downtime', tags: [high_importance_tag, downtime_tag])
      critical_importance_downtime = double(title: 'critical_importance, downtime',  tags: [critical_importance_tag, downtime_tag])

      sorted_time_groups = described_class.new(@task_categories).importance_sorted_time_groups(
        [
          # a time group, e.g. first thing
          [
            # downtime
            [
              low_importance_downtime, high_importance_downtime, critical_importance_downtime, medium_importance_downtime
            ],
            # chores
            [
              medium_importance_chore, critical_importance_chore, low_importance_chore, high_importance_chore,
            ]
          ],

          # a time group, e.g. afternoon
          [
            # admin tasks
            [
              medium_importance_admin, critical_importance_admin, low_importance_admin, high_importance_admin,
            ],

            # research
            [
              low_importance_research, high_importance_research, critical_importance_research, medium_importance_research
            ],

            # chores
            [
              medium_importance_chore, critical_importance_chore, low_importance_chore, high_importance_chore,
            ]
          ]
        ]
      )

      # TIME GROUP 1 / Downtime tasks
      expect(sorted_time_groups[0][0][0].title).to eq('critical_importance, downtime')
      expect(sorted_time_groups[0][0][1].title).to eq('high_importance, downtime')
      expect(sorted_time_groups[0][0][2].title).to eq('med_importance, downtime')
      expect(sorted_time_groups[0][0][3].title).to eq('low_importance, downtime')

      # TIME GROUP 1 / Chores
      expect(sorted_time_groups[0][1][0].title).to eq('critical_importance, chore')
      expect(sorted_time_groups[0][1][1].title).to eq('high_importance, chore')
      expect(sorted_time_groups[0][1][2].title).to eq('med_importance, chore')
      expect(sorted_time_groups[0][1][3].title).to eq('low_importance, chore')

      # TIME GROUP 2 / Admin tasks
      expect(sorted_time_groups[1][0][0].title).to eq('critical_importance, admin')
      expect(sorted_time_groups[1][0][1].title).to eq('high_importance, admin')
      expect(sorted_time_groups[1][0][2].title).to eq('med_importance, admin')
      expect(sorted_time_groups[1][0][3].title).to eq('low_importance, admin')

      # TIME GROUP 2 / Research
      expect(sorted_time_groups[1][1][0].title).to eq('critical_importance, research')
      expect(sorted_time_groups[1][1][1].title).to eq('high_importance, research')
      expect(sorted_time_groups[1][1][2].title).to eq('med_importance, research')
      expect(sorted_time_groups[1][1][3].title).to eq('low_importance, research')

     # TIME GROUP 2 / Chores
      expect(sorted_time_groups[1][2][0].title).to eq('critical_importance, chore')
      expect(sorted_time_groups[1][2][1].title).to eq('high_importance, chore')
      expect(sorted_time_groups[1][2][2].title).to eq('med_importance, chore')
      expect(sorted_time_groups[1][2][3].title).to eq('low_importance, chore')
    end
  end

  describe '#sort_task_group_by_importance' do
    xit 'sorts a group of tasks by importance' do
      low_importance_tag     = double(title: 'imp:low')
      medium_importance_tag  = double(title: 'imp:medium')
      high_importance_tag    = double(title: 'imp:high')
      critical_importance_tag = double(title: 'imp:critical')

      low_importance_task     = double(title: 'low_importance_task',     tags: [low_importance_tag])
      medium_importance_task  = double(title: 'medium_importance_task',  tags: [medium_importance_tag])
      high_importance_task    = double(title: 'high_importance_task',    tags: [high_importance_tag])
      critical_importance_task = double(title: 'critical_importance_task', tags: [critical_importance_tag])

      sorted_tasks = described_class.new(@task_categories).sort_task_group_by_importance([
        high_importance_task,
        low_importance_task,
        critical_importance_task,
        medium_importance_task,
      ])

      expect(sorted_tasks[0].title).to eq('critical_importance_task')
      expect(sorted_tasks[1].title).to eq('high_importance_task')
      expect(sorted_tasks[2].title).to eq('medium_importance_task')
      expect(sorted_tasks[3].title).to eq('low_importance_task')
    end
  end

  describe '#importance_sorted_task_groups' do
    xit 'ranks and sorts (nested) groups of tasks based on their highest rated task for a given group' do
      # TAGS
      # -----
      # what: tags
      chore_tag         = double(title: 'what:chore')
      admin_tag         = double(title: 'what:admin')
      downtime_tag      = double(title: 'what:downtime')
      research_tag      = double(title: 'what:research')

      # imp: tags
      low_importance_tag     = double(title: 'imp:low')
      medium_importance_tag  = double(title: 'imp:medium')
      high_importance_tag    = double(title: 'imp:high')
      critical_importance_tag = double(title: 'imp:critical')

      # TASKS
      # -----
      # research
      low_importance_research     = double(title: 'low_importance, research',  tags: [low_importance_tag, research_tag])
      medium_importance_research  = double(title: 'med_importance, research',  tags: [medium_importance_tag, research_tag])
      high_importance_research    = double(title: 'high_importance, research', tags: [high_importance_tag, research_tag])
      critical_importance_research = double(title: 'critical_importance, research',  tags: [critical_importance_tag, research_tag])

      # chores
      low_importance_chore     = double(title: 'low_importance, chore',  tags: [low_importance_tag, chore_tag])
      medium_importance_chore  = double(title: 'med_importance, chore',  tags: [medium_importance_tag, chore_tag])
      high_importance_chore    = double(title: 'high_importance, chore', tags: [high_importance_tag, chore_tag])
      critical_importance_chore = double(title: 'critical_importance, chore',  tags: [critical_importance_tag, chore_tag])

      # admin tasks
      low_importance_admin     = double(title: 'low_importance, admin',  tags: [low_importance_tag, admin_tag])
      medium_importance_admin  = double(title: 'med_importance, admin',  tags: [medium_importance_tag, admin_tag])
      high_importance_admin    = double(title: 'high_importance, admin', tags: [high_importance_tag, admin_tag])
      critical_importance_admin = double(title: 'critical_importance, admin',  tags: [critical_importance_tag, admin_tag])

      # downtime tasks
      low_importance_downtime     = double(title: 'low_importance, downtime',  tags: [low_importance_tag, downtime_tag])
      medium_importance_downtime  = double(title: 'med_importance, downtime',  tags: [medium_importance_tag, downtime_tag])
      high_importance_downtime    = double(title: 'high_importance, downtime', tags: [high_importance_tag, downtime_tag])
      critical_importance_downtime = double(title: 'critical_importance, downtime',  tags: [critical_importance_tag, downtime_tag])

      sorted_time_groups = described_class.new(@task_categories).importance_sorted_task_groups(
        [
          # a time group, e.g. first thing
          [
            # a task group, e.g. research
            [
              low_importance_research, low_importance_research
            ],
            # a task group, e.g. downtime
            [
              medium_importance_downtime, low_importance_downtime, low_importance_downtime
            ],
            # a task group, e.g. chores
            [
              high_importance_chore, medium_importance_chore, low_importance_chore
            ],
            # a task group, e.g. admin
            [
              critical_importance_admin, medium_importance_admin, low_importance_admin, high_importance_admin
            ]
          ],
          # a time group, e.g. first thing
          [
            # a task group, e.g. research
            [
              low_importance_admin, low_importance_admin
            ],
            # a task group, e.g. downtime
            [
              medium_importance_chore, low_importance_chore, low_importance_chore
            ],
            # a task group, e.g. chores
            [
              high_importance_research, medium_importance_research, low_importance_research
            ],
            # a task group, e.g. admin
            [
              critical_importance_downtime, medium_importance_downtime, low_importance_downtime, high_importance_downtime
            ]
          ]
        ]
      )

      # TIME GROUP 1 / Chores
      expect(sorted_time_groups[0][0][0].title).to eq('critical_importance, admin')
      expect(sorted_time_groups[0][1][0].title).to eq('high_importance, chore')
      expect(sorted_time_groups[0][2][0].title).to eq('med_importance, downtime')
      expect(sorted_time_groups[0][3][0].title).to eq('low_importance, research')

      # TIME GROUP 1 / Downtime tasks
      expect(sorted_time_groups[1][0][0].title).to eq('critical_importance, downtime')
      expect(sorted_time_groups[1][1][0].title).to eq('high_importance, research')
      expect(sorted_time_groups[1][2][0].title).to eq('med_importance, chore')
      expect(sorted_time_groups[1][3][0].title).to eq('low_importance, admin')

      # TIME GROUP 2 / Admin tasks
      # expect(sorted_time_groups[1][0][0].title).to eq('critical_importance, admin')
      # expect(sorted_time_groups[1][0][1].title).to eq('high_importance, admin')
      # expect(sorted_time_groups[1][0][2].title).to eq('med_importance, admin')
      # expect(sorted_time_groups[1][0][3].title).to eq('low_importance, admin')

      # TIME GROUP 2 / Research
      # expect(sorted_time_groups[1][1][0].title).to eq('critical_importance, research')
      # expect(sorted_time_groups[1][1][1].title).to eq('high_importance, research')
      # expect(sorted_time_groups[1][1][2].title).to eq('med_importance, research')
      # expect(sorted_time_groups[1][1][3].title).to eq('low_importance, research')

      # TIME GROUP 2 / Chores
      # expect(sorted_time_groups[1][2][0].title).to eq('critical_importance, chore')
      # expect(sorted_time_groups[1][2][1].title).to eq('high_importance, chore')
      # expect(sorted_time_groups[1][2][2].title).to eq('med_importance, chore')
      # expect(sorted_time_groups[1][2][3].title).to eq('low_importance, chore')
    end
  end
end
