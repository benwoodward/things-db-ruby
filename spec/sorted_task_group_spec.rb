require 'spec_helper'

describe SortedTaskGroup do
  before do
    @task_categories = {
      chores:        ['what:chore'],
      focussed_work: ['what:focussed-work', 'what:code', 'what:research'],
      other:         nil,
      errands:       ['what:errand', 'what:shopping-trip', 'what:appointment'],
      admin:         ['what:admin', 'what:phonecall', 'what:email', 'what:message'],
      downtime:      ['what:downtime', 'what:to-watch', 'what:to-read']
    }
  end

  describe '#tasks' do
    it 'returns all the tasks in the task group' do

    end
  end

  describe '#sort_by_importance' do
    xit "sorts the group's tasks by importance" do
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

      tasks = [
        chore1,
        message,
        errand1,
        other,
        email,
        chore2,
        phonecall,
        errand2
      ]
      grouped_tasks = described_class.new(tasks: tasks, task_categories: @task_categories).grouped_by_task_type

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
end

