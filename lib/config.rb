require 'sequel'

DEFAULT_DB="/Users/#{`whoami`.chop}/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application Support/Cultured Code/Things/Things.sqlite3"
DB = Sequel.sqlite(DEFAULT_DB)

GIST_ID=ENV['GIST_ID']
GITHUB_THINGS_TOKEN=ENV['GITHUB_THINGS_TOKEN']
MAX_MINUTES=8*60

