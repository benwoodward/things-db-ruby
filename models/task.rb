require 'sequel'
require 'sqlite3'

class Task < Sequel::Model(DB[:TMTask])
  many_to_many :tags, left_key: :tasks, right_key: :tags,
    join_table: :TMTaskTag
end
