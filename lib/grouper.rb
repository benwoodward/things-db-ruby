class Grouper
  attr_accessor :groupings

  def initialize(tasks, tagging_groups, catch_all:)
    @tasks = tasks
    @tagging_groups = tagging_groups
    @catch_all_category = catch_all
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
      if add_to_category?(task)
        next
      else
        groupings[@catch_all_category] << task
      end
    end

    # groupings[:admin] = group_by_admin_subgroup(groupings[:admin])
    groupings
  end

  def add_to_category?(task)
    @tagging_groups.each do |category, tags|
      if contains_specified_tags?(task.tags, tags)
        groupings[category] << task
        return true
      end
    end

    false
  end

  def contains_specified_tags?(tags, tag_names)
    return false if tags.nil? or tag_names.nil?
    tags.select {|tag| tag_names.include?(tag.title) }.count > 0
  end
end
