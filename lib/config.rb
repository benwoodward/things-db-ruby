require 'sequel'

DEFAULT_DB="/Users/#{`whoami`.chop}/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application Support/Cultured Code/Things/Things.sqlite3"
DB = Sequel.sqlite(DEFAULT_DB)

MAX_MINUTES=8*60

