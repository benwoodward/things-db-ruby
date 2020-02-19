class Logger
  def self.print_task_list(tasks)
    return if ENV['SCRIPT_ENV'] == 'test'

    tasks.each do |time_group|
      puts "\n::::IMP. Sorted TIME GROUP::::"
      puts "======="
      time_group.each do |task_group|
        puts "\n::::task group::::"
        puts "======="
        task_group.each do |task|
          puts task.title
          puts '---'
          puts task.tags.map {|tag| tag.title}.join(',')
          puts "\n\n\n"
        end
      end
      puts "\n\n"
    end
  end
end
