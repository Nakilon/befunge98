require "minitest/autorun"

require_relative "lib/befunge98"

describe "lib" do

  it "prints to STDOUT" do skip end
  it "prints to String" do skip end

  describe "Befunge93 operations" do
    describe "(rely on @)" do
      before do
        _, _, exitcode = Befunge98(?@)
        assert_equal 0, exitcode
      end

      it ?" do
        _, stack, _ = Befunge98('"@')
        assert_equal [?@.ord], stack
      end

      describe "(rely on 0..9)" do
        before do
          _, stack, _ = Befunge98('0123456789@')
          assert_equal (0..9).to_a, stack
        end

        it "1 2 $" do
          _, stack, _ = Befunge98('12$@')
          assert_equal [1], stack
        end
        it "1 2 :" do
          _, stack, _ = Befunge98('12:@')
          assert_equal [1, 2, 2], stack
        end
        it "1 2 3 \\" do
          _, stack, _ = Befunge98('123\\@')
          assert_equal [1, 3, 2], stack
        end
        it "1 #" do
          _, stack, _ = Befunge98('#@1#')
          assert_equal [1], stack
        end
      end
    end
  end

  describe "Befunge98 operations" do
    it ?q do
      _, _, exitcode = Befunge98(?q)
      assert_equal 0, exitcode
      _, _, exitcode = Befunge98("1q")
      assert_equal 1, exitcode
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
