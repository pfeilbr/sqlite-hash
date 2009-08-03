require 'test/unit'
require 'FileUtils'

require 'sqlitehash'

class TestSQLiteHash < Test::Unit::TestCase

  include FileUtils

  def setup
    @dir = "#{Dir.pwd}/temp_testing"
    mkdir_p @dir
  end
  
  def teardown
    rm_rf @dir
  end
  
  def get_new_hash
    SQLiteHash.new "#{@dir}/#{Time.now.to_i}.sqlite"
  end
  
  def test_empty
    h = get_new_hash
    assert h.size == 0, "size of empty hash not equal to 0"
  end
  
  def test_size
    h = get_new_hash
    h['name'] = 'brian'
    h['age'] = '31'
    assert h.size == 2, "size test failed"
  end
  
  def test_store_string
    h = get_new_hash
    h['name'] = 'brian'
    assert h['name'] == 'brian', "storing and retrieving string value failed"
  end
  
  def test_include?
    h = get_new_hash
    h['name'] = 'brian'
    assert h.include?('name'), "include? test failed"
  end
  
  def test_each
    h = get_new_hash
    h['name'] = 'brian'
    result = false
    h.each {|key, value| result = (key == 'name' && value == 'brian') }
    assert result, "each test failed"
  end
  
end