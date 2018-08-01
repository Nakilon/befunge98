require "minitest/autorun"

require_relative "lib/befunge98"

describe "lib" do

  it "prints to STDOUT" do skip end
  it "prints to String" do skip end

  describe "Befunge93 operations" do
    it ?@ do
      _, code = Befunge98(?@)
      assert_equal 0, code
    end
  end

  describe "Befunge98 operations" do
    it ?q do
      _, code = Befunge98(?q)
      assert_equal 0, code
      _, code = Befunge98("1q")
      assert_equal 1, code
    end
  end

end

describe "bin" do

  it "hello world" do
    require "open3"
    require "tempfile"
    file = Tempfile.new "temp.bf98"
    begin
      file.write '64+"!dlroW ,olleH">:#,_@'
      file.flush
      string, status = Open3.capture2e "bundle exec ruby bin/befunge98 #{file.path}"
    ensure
      file.close
      file.unlink
    end
    assert_equal ["Hello, World!\n", 0], [string, status.exitstatus]
  end

end
