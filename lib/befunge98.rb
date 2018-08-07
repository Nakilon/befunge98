STDOUT.sync = true

def Befunge98 source, stdout = StringIO.new, stdin = STDIN
  code = source.split ?\n

  stacks = [stack = []]
  pop = ->{ stack.pop || 0 }

  ox = oy = 0
  ds = [[0,1], [1,0], [-0,1], [-1,0]]
  dx, dy = 1, 0
  px, py = -1, 0
  go_west = ->{ dx, dy = -1, 0 }
  go_east = ->{ dx, dy = 1, 0 }
  go_north = ->{ dx, dy = 0, -1 }
  go_south = ->{ dx, dy = 0, 1 }
  move = lambda do
    # TODO: Lahey-space wrapping
    (py += dy; py %= code.size) if dy != 0
    (px += dx; px %= code[py].size) if dx != 0
  end

  stringmode = false
  iterate = 0
  jump_over = false

  loop do
    if iterate.zero?
      move[]
      char = (code[py] || "")[px] || ?\s
    else
      iterate -= 1
    end

    next if jump_over && char != ?;

    p [stack, char] if ENV["DEBUG"]
    next stack << char.ord if stringmode && char != ?"
    next unless (32..126).include? char.ord
    reflect = ->{ dy, dx = [-dy, -dx] }
    case char
      ### 93
      when ?" ; stringmode ^= true
      when ?0..?9 ; stack << char.to_i
      when ?$ ; pop[]
      when ?: ; stack.concat [pop[]] * 2
      when ?\\ ; stack.concat [pop[], pop[]]
      when ?# ; move[]
      when ?> ; go_east[]
      when ?< ; go_west[]
      when ?^ ; go_north[]
      when ?v ; go_south[]
      when ?? ; [go_east, go_west, go_north, go_south].sample[]
      when ?+ ; stack << (pop[] + pop[])
      when ?- ; stack << -(pop[] - pop[])
      when ?* ; stack << (pop[] * pop[])
      when ?/ ; b, a = pop[], pop[]; stack << (b.zero? ? 0 : a / b)
      when ?% ; b, a = pop[], pop[]; stack << (b.zero? ? 0 : a % b)
      when ?| ; pop[].zero? ? go_south[] : go_north[]
      when ?_ ; pop[].zero? ? go_east[] : go_west[]
      when ?~
        if c = stdin.getc
          stack << c.bytes.tap{ |_| _.size == 1 or fail }.first
        else
          reflect[]
        end
      when ?&
        catch nil do
          begin
            unless c = stdin.getc
              reflect[]
              throw nil
            end
          end until (?0..?9).include?(c)
          while (
            unless cc = stdin.getc
              reflect[]
              throw nil
            end
            (?0..?9).include? cc
          )
            c.concat cc
          end
          stack << c.to_i
        end
      when ?, ; stdout.print pop[].chr            # ask about cells larger than byte
      when ?. ; stdout.print ("%d " % pop[])
      when ?! ; stack << (pop[].zero? ? 1 : 0)
      when ?` ; stack << (pop[]<pop[] ? 1 : 0)
      when ?p
        y, x, v = pop[], pop[], pop[]
        code[oy + y] = "" unless code[y]
        code[oy + y][ox + x] = v.chr
      when ?g
        y, x = pop[], pop[]
        stack << ((code[oy + y] || "")[ox + x] || ?\s).ord
        # https://github.com/catseye/Funge-98/blob/master/doc/funge98.markdown
        # A Funge-98 program should also be able to rely on the memory mechanism acting as
        # if a cell contains blank space (ASCII 32) if it is unallocated, and setting memory
        # to be full of blank space cells upon actual allocation (program load, or p instruction)
      when ?@ ; return Struct.new(:stdout, :stack, :exitcode).new(stdout, stack, 0)
      ### 98
      when ?q ; return Struct.new(:stdout, :stack, :exitcode).new(stdout, stack, pop[])
      when ?a..?f ; stack << char.ord - ?a.ord + 10
      when ?n ; stack.clear
      when ?'
        move[]
        stack << ((code[y] || "")[x] || ?\s).ord
      when ?s
        move[]
        code[py] = "" unless code[py]   # do we really need this?
        code[py] = code[py].ljust px + 1
        code[py][px] = pop[].chr
      when ?; ; jump_over ^= true
      when ?] ; dy, dx = ds[(ds.index([dy, dx]) + 1) % ds.size]
      when ?[ ; dy, dx = ds[(ds.index([dy, dx]) - 1) % ds.size]
      when ?w ; dy, dx = ds[(ds.index([dy, dx]) + (pop[] > pop[] ? -1 : 1)) % ds.size]
      when ?r ; reflect[]
      when ?x ; dy, dx = [pop[], pop[]] # ask if |delta|>1 is possible
      when ?j
        if 0 < t = pop[]
          t.times{ move[] }
        else
          reflect[]
          t.times{ move[] }
          reflect[]
        end
      when ?k
        iterate = pop[]
        begin
          move[]
          char = (code[py] || "")[px] || ?\s
        end until char != ?\s || char != ?;
      when ?{
        # stacks << toss = if 0 > n = pop[]
        #   Array.new(-n, 0)
        # else
        #   Array.new(n){ pop[] }
        # end
        n = pop[]
        toss = Array.new n unless toss = stack[stack.size-n..stack.size]
        stack << ox << oy
        ox = px + dx
        oy = py + dy
        stacks << stack = toss
      when ?{
        if 1 == stacks.size
          reflect[]
        else
          toss = stack
          t = (0 < n = pop[]) ? stack.last(n) : []
          stack = stacks.tap(&:pop).last
          oy, ox = pop[], pop[]
          stack.concat t
        end
      when ?u
        if 1 == stacks.size
          reflect[]
        elsif 0 < n = pop[]
          n.times{ stack << stack[1].pop }
        else
          n.times{ stack[1] << pop[] }
        end
      when ?(, ?)
        pop[].times.inject(0){ |i,| i*256 + pop[] }
        reflect[]
      when ?y
        y = pop[]
        ss = stack.size
        stack << 0
        stack << 255
        stack << 0
        stack << Gem.loaded_specs.values.find{ |_| _.lib_dirs_glob == File.absolute_path(__dir__) }.version.segments.join.to_i
        stacK << 0
        stack << File::SEPARATOR.ord
        stack << 2
        stack << 0
        stack << 0
        stack << py << px
        stack << dy << dx
        stack << oy << ox
        stack << [0, 0] # TODO: 1 vector containing the least point which contains a non-space cell, relative to the origin (env)
        stack << [0, 0] # TODO: 1 vector containing the greatest point which contains a non-space cell, relative to the least point (env)
        t = Time.now
        stack << (t.year - 1900) * 256 * 256 + t.month * 256 + t.day
        stack << t.hour * 256 * 256 + t.min * 256 + t.sec
        stack << stacks.size
        stack.concat stacks.map &:size; stack[-1] = ss
        stack.concat ARGV.map{ |_| _.chars.map(&:ord) + [0] } + [0]
        stack.concat ENV.map{ |k, v| "#{k}=#{v}".chars.map(&:ord) + [0] } + [0]
        stack << stack[1-y].tap{ stack = stack.take ss } if y > 0
    end
  end
end
