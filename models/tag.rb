require 'sequel'
require 'sqlite3'

class Tag < Sequel::Model(DB[:TMTag])
  many_to_many :tasks, left_key: :tags, right_key: :tasks,
    join_table: :TMTaskTag
end
