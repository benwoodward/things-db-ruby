require 'sequel'
require 'sqlite3'

class Task < Sequel::Model(DB[:TMTask])
  many_to_many :tags, left_key: :tasks, right_key: :tags,
    join_table: :TMTaskTag

  def importance_tag_scores
    config = { 'imp:low':  1, 'imp:medium':  2, 'imp:high': 3, 'imp:critical': 4, nil => 0 }
    config.default = 0
    config
  end

  def importance
    importance_tag_scores[tags_sorted_by_importance.first.title.to_sym]
  end

  def tags_sorted_by_importance
    tags.sort_by do |tag|
      importance_tag_scores[tag.title.to_sym]
    end.reverse
  end
end
