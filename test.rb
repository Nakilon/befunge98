require "minitest/autorun"

require_relative "lib/befunge98"

describe "lib" do

  it "prints to STDOUT" do skip end
  it "prints to String" do skip end

  describe "Befunge93 operations" do
    describe "(rely on @)" do
      before do
        assert_equal 0, Befunge98(?@).exitcode
      end

      it ?" do
        assert_equal [?@.ord], Befunge98('"@').stack
      end

      describe "(rely on 0..9)" do
        before do
          assert_equal (0..9).to_a, Befunge98('0123456789@').stack
        end

        it ?$ do
          assert_equal [1], Befunge98('$12$@').stack
        end
        it ?: do
          assert_equal [0, 0, 1, 1], Befunge98(':1:@').stack
        end
        it ?\ do
          assert_equal [0, 1, 0], Befunge98('\\1\\@').stack
        end
        it ?# do
          assert_equal [1], Befunge98('#@1#').stack
        end
        it "><^v" do
          assert_equal [1, 2, 3, 4], Befunge98("<@^1\n"\
                                               "3v>\n"\
                                               "5425").stack
        end
        it ?? do
          t = []
          100.times do
            t |= Befunge98("?1@2\n"\
                           "4555\n"\
                           "@555\n"\
                           "3555").stack
          end
          assert_equal [1, 2, 3, 4], t.uniq.sort
        end
      end
    end

    it "# test by @lifthrasiir" do
      assert_equal "3 ", Befunge98("#;v           ; 1.@\n"\
                                   "  ># ;2.@;3.@").stdout.string
    end
  end

  describe "Befunge98 operations" do
    it ?q do
      assert_equal 0, Befunge98(?q).exitcode
      assert_equal 1, Befunge98("1q").exitcode
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
