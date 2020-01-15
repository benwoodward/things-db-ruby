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
