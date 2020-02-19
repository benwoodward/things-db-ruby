class Formatter
  class << self
    def todays_tasks_as_json(tasks)
      todays_tasks = []
      combined_duration = 0

      tasks.each do |task|
        duration = duration_in_minutes(task.tags)

        task = {
          things_url: things_url(task[:uuid]),
          content: task_content(task),
          duration: duration
        }

        todays_tasks << JSON.generate(task)

        break if combined_duration >= MAX_MINUTES
        combined_duration += duration.to_i
      end

      todays_tasks
    end

    def duration_in_minutes(tags)
      dur_tag = tags.select {|tag| tag.title =~ /dur:/}.first
      if dur_tag.nil?
        return 15
      else
        extract_minutes_from_dur_string(dur_tag.title)
      end
    end

    def extract_minutes_from_dur_string(str)
      if str =~ /m|min/
        minute_string_to_minutes(str)
      elsif str =~ /h|hr|hour/
        hour_string_to_minutes(str)
      end
    end

    def extract_number_from_string(str)
      str.gsub(/[a-zA-Z:]/, '').to_i
    end

    def minute_string_to_minutes(duration)
      extract_number_from_string(duration)
    end

    def hour_string_to_minutes(duration)
      hours = extract_number_from_string(duration)
      (hours.to_i * 60).to_i
    end

    def things_url(id)
      "things:///show?id=#{id}"
    end
  end
end
