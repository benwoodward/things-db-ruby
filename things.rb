require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'

DEFAULT_DB="/Users/#{`whoami`.chop}/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application Support/Cultured Code/Things/Things.sqlite3"

DB = Sequel.sqlite(DEFAULT_DB)

DB['select * from TMTask limit 10'].each do |row|
  p row
end
