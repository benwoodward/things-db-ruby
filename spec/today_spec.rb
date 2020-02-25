require 'spec_helper'

describe Today do
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

  describe '#time_groups' do
    it 'converts an array of tasks into a hash of SortedTimeGroups' do
      first_thing_tag = double(title: 'when:first-thing')
      morning_tag = double(title: 'when:morning')
      afternoon_tag = double(title: 'when:afternoon')
      evening_tag = double(title: 'when:evening')
      anytime_tag = double(title: 'randomstring')

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

      tasks = [
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
      ]

      time_groups = described_class.new(
        tasks: tasks,
        times_of_day_tags: @times_of_day_tags,
        task_categories: @task_categories
      ).time_groups()

      expect(time_groups[:first_thing].tasks[0].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(time_groups[:first_thing].tasks[1].title).to eq('first_thing_task1').or eq('first_thing_task2')
      expect(time_groups[:morning].tasks[0].title).to eq('morning_task1').or eq('morning_task2')
      expect(time_groups[:morning].tasks[1].title).to eq('morning_task1').or eq('morning_task2')
      expect(time_groups[:anytime].tasks[0].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(time_groups[:anytime].tasks[1].title).to eq('anytime_task1').or eq('anytime_task2')
      expect(time_groups[:afternoon].tasks[0].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(time_groups[:afternoon].tasks[1].title).to eq('afternoon_task1').or eq('afternoon_task2')
      expect(time_groups[:evening].tasks[0].title).to eq('evening_task1').or eq('evening_task2')
      expect(time_groups[:evening].tasks[1].title).to eq('evening_task1').or eq('evening_task2')
    end

    # XXX: This will fail if you don't have a today task tagged 'when:first-thing' available
    it 'loads tasks from database by default' do
      time_groups = described_class.new(
        tasks: nil,
        times_of_day_tags: @times_of_day_tags,
        task_categories: @task_categories
      ).time_groups()

      expect(time_groups[:first_thing].tasks[0].title).to be_a(String)
    end
  end
end
