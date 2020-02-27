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

  describe '#sorted_tasks' do
    it 'converts an array of tasks into a hash of SortedTimeGroups' do
      # when: tags
      first_thing_tag     = double(title: 'when:first-thing')
      morning_tag         = double(title: 'when:morning')
      afternoon_tag       = double(title: 'when:afternoon')
      evening_tag         = double(title: 'when:evening')
      anytime_tag         = double(title: 'randomstring')

      # what: tags
      chore_tag           = double(title: 'what:chore')
      focussed_work_tag   = double(title: 'what:focussed')
      other_tag           = double(title: 'what:other')
      errand_tag          = double(title: 'what:errand')
      admin_tag           = double(title: 'what:admin')
      downtime_tag        = double(title: 'what:downtime')

      # urg: tags
      low_urgency_tag     = double(title: 'urg:low')
      medium_urgency_tag  = double(title: 'urg:medium')
      high_urgency_tag    = double(title: 'urg:high')
      asap_urgency_tag    = double(title: 'urg:asap')

      first_thing_chore1 = double(title: 'first thing, chore, low urgency', tags: [first_thing_tag, chore_tag, low_urgency_tag])
      first_thing_chore2 = double(title: 'first thing, chore, medium urgency', tags: [first_thing_tag, chore_tag, medium_urgency_tag])
      first_thing_chore3 = double(title: 'first thing, chore, high urgency', tags: [first_thing_tag, chore_tag, high_urgency_tag])
      afternoon_chore1   = double(title: 'afternoon, chore, low urgency', tags: [afternoon_tag, chore_tag, low_urgency_tag])
      afternoon_chore2   = double(title: 'afternoon, chore, medium urgency', tags: [afternoon_tag, chore_tag, medium_urgency_tag])
      afternoon_chore3   = double(title: 'afternoon, chore, high urgency', tags: [afternoon_tag, chore_tag, high_urgency_tag])

      morning_admin1 = double(title: 'morning, admin, low urgency', tags: [morning_tag, admin_tag, low_urgency_tag])
      morning_admin2 = double(title: 'morning, admin, medium urgency', tags: [morning_tag, admin_tag, medium_urgency_tag])
      morning_admin3 = double(title: 'morning, admin, high urgency', tags: [morning_tag, admin_tag, high_urgency_tag])
      afternoon_errand1 = double(title: 'afternoon, errand, low urgency', tags: [afternoon_tag, errand_tag, low_urgency_tag])
      afternoon_errand2 = double(title: 'afternoon, errand, medium urgency', tags: [afternoon_tag, errand_tag, medium_urgency_tag])
      afternoon_errand3 = double(title: 'afternoon, errand, high urgency', tags: [afternoon_tag, errand_tag, high_urgency_tag])

      morning_admin1 = double(title: 'morning, admin, low urgency', tags: [morning_tag, admin_tag, low_urgency_tag])
      morning_admin2 = double(title: 'morning, admin, medium urgency', tags: [morning_tag, admin_tag, medium_urgency_tag])
      morning_admin3 = double(title: 'morning, admin, high urgency', tags: [morning_tag, admin_tag, high_urgency_tag])
      afternoon_errand1 = double(title: 'afternoon, errand, low urgency', tags: [afternoon_tag, errand_tag, low_urgency_tag])
      afternoon_errand2 = double(title: 'afternoon, errand, medium urgency', tags: [afternoon_tag, errand_tag, medium_urgency_tag])
      afternoon_errand3 = double(title: 'afternoon, errand, asap urgency', tags: [afternoon_tag, errand_tag, asap_urgency_tag])

      anytime_downtime1 = double(title: 'anytime, downtime, low urgency', tags: [anytime_tag, downtime_tag, low_urgency_tag])
      anytime_downtime2 = double(title: 'anytime, downtime, medium urgency', tags: [anytime_tag, downtime_tag, medium_urgency_tag])
      anytime_downtime3 = double(title: 'anytime, downtime, high urgency', tags: [anytime_tag, downtime_tag, high_urgency_tag])
      first_thing_other1 = double(title: 'first thing, other, low urgency', tags: [first_thing_tag, other_tag, low_urgency_tag])
      first_thing_other2 = double(title: 'first thing, other, medium urgency', tags: [first_thing_tag, other_tag, medium_urgency_tag])
      first_thing_other3 = double(title: 'first thing, other, asap urgency', tags: [first_thing_tag, other_tag, asap_urgency_tag])

      tasks = [
        morning_admin2, morning_admin3,
        afternoon_errand2, first_thing_chore1,
        afternoon_chore2, first_thing_chore2,
        afternoon_chore3, first_thing_chore3,
        afternoon_errand1, morning_admin1,
        morning_admin2, morning_admin3,
        anytime_downtime3, afternoon_errand1,
        morning_admin1, first_thing_other2,
        afternoon_chore1, afternoon_errand3,
        first_thing_other1, afternoon_errand2,
        afternoon_errand3, anytime_downtime1,
        first_thing_other3, anytime_downtime2,
      ]

      today = described_class.new(
        tasks: tasks,
        times_of_day: @times_of_day_tags,
        task_categories: @task_categories
      ).sorted_tasks()

      expect(today[:first_thing]).to be_a(SortedTimeGroup)
      expect(today[:first_thing].groups.values.first).to be_a(SortedTaskGroup)
      # expect(sorted_tasks[:first_thing].tasks[0].title).to eq('first thing, chore, high urgency')
      # expect(sorted_tasks[:first_thing].tasks[1].title).to eq('first thing, chore, medium urgency')
      # expect(sorted_tasks[:first_thing].tasks[2].title).to eq('first thing, chore, low urgency')
    end

    # XXX: This will fail if you don't have a today task tagged 'when:first-thing' available
    it 'loads tasks from database by default' do
      time_groups = described_class.new(
        tasks: nil,
        times_of_day: @times_of_day_tags,
        task_categories: @task_categories
      ).groups()

      expect(time_groups[:first_thing].tasks[0].title).to be_a(String)
    end
  end
end
