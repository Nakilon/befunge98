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
      it ?~ do
        stdin = StringIO.new
        stdin.set_encoding "ascii"
        stdin.print "\0\x0a\xff"
        stdin.rewind
        assert_equal [0, 10, 255], Befunge98("~~~@", StringIO.new, stdin).stack
      end
      it ?& do
        stdin = StringIO.new
        stdin.set_encoding "ascii"
        stdin.puts "-12345\n\n67890"
        stdin.rewind
        assert_equal [12345, 67890], Befunge98("&&@", StringIO.new, stdin).stack
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
          100000.times do
            t |= Befunge98("?1@2\n"\
                           "4555\n"\
                           "@555\n"\
                           "3555").stack
          end
          assert_equal [1, 2, 3, 4], t.uniq.sort
        end
        it ?+ do
          assert_equal [90000], Befunge98("++"+"9+"*10000+"@").stack
        end
        it ?- do
          assert_equal [-90000], Befunge98("--"+"9-"*10000+"@").stack
        end
        it ?* do
          assert_equal [0, 2**31], Befunge98("**2*2"+"2*"*30+"@").stack
        end
        it ?/ do
          assert_equal [0, 0, 1, 2], Befunge98("//12/22/21/@").stack
        end
        it "-/" do
          assert_equal [-1, -2, -1, -2], Befunge98("1-2/02-1/102-/201-/@").stack
        end
        it "|_" do ; skip
          assert_equal [1, 3], Befunge98("  |\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
          assert_equal [2, 4], Befunge98("11|\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
        end
        it "-|_" do
          assert_equal [2, 4], Befunge98("1-01-|\n"\
                                         "   41_13@\n"\
                                         "   42_23@").stack
        end
        it ?~ do
          stdin = StringIO.new
          stdin.set_encoding "ascii"
          assert_equal [2], Befunge98("~1@2", StringIO.new, stdin).stack
        end
        it ?& do
          stdin = StringIO.new
          stdin.set_encoding "ascii"
          assert_equal [2], Befunge98("&1@2", StringIO.new, stdin).stack
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
