require "minitest/autorun"
require_relative "lib/befunge98"

describe "lib" do
  it "prints to STDOUT" do skip end
  it "prints to String" do skip end

  describe "Befunge-93" do
    describe "(rely on @ and pop from empty stack)" do
      before do
        assert_equal 0, Befunge98(?@).exitcode
      end

      it '"' do
        assert_equal [?@.ord], Befunge98("\"@").stack
      end

      describe "(rely on 0..9)" do
        before do
          assert_equal (0..9).to_a, Befunge98("0123456789@").stack
        end

        it "$" do
          assert_equal [1], Befunge98("$12$@").stack
        end
        it ":" do
          assert_equal [0, 0, 1, 1], Befunge98(":1:@").stack
        end
        it "\\" do
          assert_equal [0, 1, 0], Befunge98("\\1\\@").stack
        end
        it "#" do
          assert_equal [1], Befunge98('#@1#').stack
        end
        it "><^v" do
          assert_equal [1, 2, 3, 4], Befunge98("<@^1\n"\
                                               "3v>\n"\
                                               "5425").stack
        end
        it "?" do
          assert_equal [[1], [2], [3], [4]], 100.times.map{
            Befunge98("?1@2\n"\
                      "4555\n"\
                      "@555\n"\
                      "3555").stack
          }.uniq.sort
        end
        it "+" do
          assert_equal [90000], Befunge98("++"+"9+"*10000+"@").stack
        end
        it "-" do
          assert_equal [-90000], Befunge98("--"+"9-"*10000+"@").stack
        end
        it "*" do
          assert_equal [0, 2**31], Befunge98("**2*2"+"2*"*30+"@").stack
        end
        it "/" do
          assert_equal [0, 0, 1, 2], Befunge98("//12/22/21/@").stack
        end
        it "/ with -" do
          assert_equal [-1, -2, -1, -2], Befunge98("1-2/02-1/102-/201-/@").stack
        end
        it "|_" do
          assert_equal [1, 3], Befunge98("00|\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
          assert_equal [2, 4], Befunge98("11|\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
          assert_equal [2, 3], Befunge98("01|\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
          assert_equal [1, 4], Befunge98("10|\n"\
                                         "41_13@\n"\
                                         "42_23@").stack
        end
        it "-|_" do
          assert_equal [2, 4], Befunge98("1-01-|\n"\
                                         "   41_13@\n"\
                                         "   42_23@").stack
        end
        describe "(rely on +)" do
          before do
            assert_equal [3], Befunge98("12+@").stack
          end
          it "," do
            assert_equal "\x00\x0A\xFF\x00".b, Befunge98(",55+,5"+"5+"*50+",,@").stdout.string
          end
          it "." do
            assert_equal "0 10 255 0 ",        Befunge98(".55+.5"+"5+"*50+"..@").stdout.string
          end
        end
        it "!" do
          assert_equal [1, 1, 0, 0], Befunge98("!0!1!2!@").stack
        end
        it "! with -" do
          assert_equal [0, 0], Befunge98("1-!02-!@").stack
        end
        it "`" do
          assert_equal [0, 0, 1], Befunge98("`01`10`@").stack
        end
      end
    end

    it "# test by @lifthrasiir" do
      assert_equal "3 ", Befunge98(
      <<~HEREDOC
        #;v           ; 1.@
          ># ;2.@;3.@
      HEREDOC
      ).stdout.string
    end
  end

  describe "Befunge98 operations" do
    it "q" do
      assert_equal 0, Befunge98(" q").exitcode
      assert_equal 1, Befunge98("1q").exitcode
    end

    describe "(rely on @)" do
      before do
        assert_equal 0, Befunge98(?@).exitcode
      end

      it "~" do
        assert_equal [2], Befunge98("~1@2", StringIO.new, StringIO.new).stack
        assert_equal [0, 10, 255, 0], Befunge98("~~~~@", StringIO.new,
          StringIO.new.tap{ |s| [0, 10, 255, 0].reverse_each &s.method(:ungetbyte) }
        ).stack
      end
      it "&" do
        assert_equal [2], Befunge98("&1@2", StringIO.new, StringIO.new).stack
        [?\0, ?\xa, ?\xff].each do |c|
          assert_equal [12, 34], Befunge98("&&@", StringIO.new,
            StringIO.new.tap{ |s| "#{c}-12#{c}-34#{c}".bytes.reverse_each &s.method(:ungetbyte) }
          ).stack
        end
      end

      describe "(rely on a..f)" do
        before do
          assert_equal (10..15).to_a, Befunge98("abcdef@").stack
        end
      end
    end
  end

end

describe "bin" do
  it "hello world" do
    require "open3"
    require "tempfile"
    file = Tempfile.new "temp.b98"
    begin
      file.write '64+"!dlroW ,olleH">:#,_@'
      file.flush
      string, status = Open3.capture2 "bundle exec ruby bin/befunge98 #{file.path}"
    ensure
      file.close
      file.unlink
    end
    assert_equal ["Hello, World!\n", 0], [string, status.exitstatus]
  end
end
