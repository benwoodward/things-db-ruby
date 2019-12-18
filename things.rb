require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'sqlite3'
require 'pry'
require 'octokit'
require 'json'

require './config'
require './models/tag'
require './models/task'
require './script'

push_to_gist

