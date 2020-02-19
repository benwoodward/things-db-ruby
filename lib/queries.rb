class Queries
  class << self
    def todays_tasks
      Task.eager(:tags)
        .where(trashed: 0, status: 0, type: 0, start: 1)
        .where(Sequel.~(startdate: nil))
        .order(:todayIndex)
        .limit(100)
    end
  end
end
