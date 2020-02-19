$LOAD_PATH.unshift File.expand_path(".", "lib")

require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'config'
require 'logger'
require 'sorter'
require 'models/tag'
require 'models/task'
require 'formatter'
require 'queries'
