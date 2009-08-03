require 'rubygems'
require 'sqlite3'
require 'FileUtils'

class SQLiteHash
  include FileUtils
  
  attr_reader :db, :path, :table_name
  
  def initialize(path = 'hash.sqlite', table_name = 'hash', options = {})
    @path = path
    @table_name = table_name

    overwrite = options[:overwrite] || false

    if overwrite && File.exists?(path)
      rm path
    end

    @db = SQLite3::Database.new(path)
    create_schema if !table_exists?(table_name)    
  end
  
  def table_exists?(name)
    @db.get_first_value( %{select name from sqlite_master where name = :name}, {:name => name} ) != nil
  end
  
  def create_schema
    table_ddl = %{
      create table #{@table_name} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key text,
        value text,
        created default CURRENT_TIMESTAMP,
        modified default CURRENT_TIMESTAMP
      );
    }
    @db.execute(table_ddl)
    
    index_ddl = %{ create index idxkey on #{@table_name} (key); }
    @db.execute(index_ddl)
  end
  
  def []=(key, value)
    if !include?(key)
      result = @db.execute( %{insert into #{@table_name} (key, value) values (:key, :value)}, {:key => key, :value => value} ) 
    else
      result = @db.execute( %{ update #{@table_name} set value = :value, modified = CURRENT_TIMESTAMP where key = :key }, {:key => key, :value => value})
    end
  end
  
  def [] key
    @db.get_first_value( %{select value from #{@table_name} where key = :key}, {:key => key} )
  end
  
  def include?(key)
    self[key] != nil
  end
  
  def each &block
    @db.execute( %{select key, value from #{@table_name} } ) do |row|
      yield row[0], row[1]
    end
  end
  
  def keys
    arr = []
    each {|key, value| arr << key }
    arr
  end
  
  def size
    keys.size
  end
  
  def to_hash
    h = {}
    each {|key, value| h[key] = value }
    h
  end
  
end
