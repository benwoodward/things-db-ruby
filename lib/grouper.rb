class Grouper
  attr_accessor :groupings

  def initialize(tasks, tagging_groups, catch_all_category)
    @tasks = tasks
    @tagging_groups = tagging_groups
    @catch_all_category = catch_all_category
  end

  def groupings
    @groupings ||= initialise_hash_of_arrays_from_keys(@tagging_groups.keys)
  end

  def initialise_hash_of_arrays_from_keys(keys)
    h = Hash.new
    keys.each {|k,_| h[k] = []}
    h
  end

  def group_by_tagging_categories
    @tasks.each do |task|
      @tagging_groups.each do |category, tags|
        if !contains_specified_tags?(task.tags, @tagging_groups.values.flatten)
          groupings[@catch_all_category] << task
        elsif contains_specified_tags?(task.tags, tags)
          groupings[category] << task
        end
      end
    end

    # groupings[:admin] = group_by_admin_subgroup(groupings[:admin])
    groupings
  end

  def contains_specified_tags?(tags, tag_names)
    return false if tags.nil? or tag_names.nil?
    tags.select {|tag| tag_names.include?(tag.title) }.count > 0
  end
end
