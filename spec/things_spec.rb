require 'spec_helper'
require 'json'

describe Sorter do
  describe '#gist_content' do
    it 'should return a string' do
      expect(described_class.gist_content).to be_a(String)
    end

    it 'should be in JSON format' do
      json = JSON.parse described_class.gist_content
      expect(json.first.keys).to include('things_url', 'content', 'duration')
    end
  end

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


      puts grouped_tasks.inspect
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
  end

  describe '#importance_sorted_task_groups' do
  end

  describe '#sorted3_order' do
  end

  describe '#tasks_to_json' do
  end
end
