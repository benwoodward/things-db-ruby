$LOAD_PATH.unshift File.expand_path(".", "lib")

require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'sorter'

Sorter.arranged_tasks

