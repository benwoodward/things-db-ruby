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

  describe '#time_groups' do
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
