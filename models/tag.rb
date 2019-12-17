require 'sequel'
require 'sqlite3'
require './config'

class Tag < Sequel::Model(DB[:TMTag])
  many_to_many :tasks, left_key: :tags, right_key: :tasks,
    join_table: :TMTaskTag
end
