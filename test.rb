require "minitest/autorun"

require_relative "lib/befunge98"

describe "Befunge98" do

  describe "./bin" do

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

end
