def Befunge98 source, stdout = StringIO.new, stdin = STDIN
  code = source.split(?\n).map(&:bytes)

  stacks = [stack = []]
  pop = ->{ stack.pop || 0 }

  ox = oy = 0
  dx, dy = 1, 0
  x, y = -1, 0
  ds = [[0,1], [1,0], [0,-1], [-1,0]]
  go_west = ->{ dx, dy = *ds[3] }
  go_east = ->{ dx, dy = *ds[1] }
  go_north = ->{ dx, dy = *ds[2] }
  go_south = ->{ dx, dy = *ds[0] }
  reflect = ->{ dy, dx = [-dy, -dx] }
  move = lambda do
    # TODO: Lahey-space wrapping
    (y += dy; y %= code.   size) if dy != 0
    (x += dx; x %= code[y].size) if dx != 0
  end

  stringmode = jump_over = false
  iterate = 0

  get = ->{ (code[y + oy] || [])[x + ox] || 32 }
  loop do
    if iterate.zero?
      move[]
      char = get[]
    else
      iterate -= 1
    end

    next stack << char if stringmode && char.chr != ?"
    next unless (33..126).include? char
    next if jump_over && char.chr != ?;
    case char.chr
      when ?; ; jump_over ^= true

      ### 93
      when ?" ; stringmode ^= true
      when ?0..?9 ; stack << char.chr.to_i
      when ?$ ; pop[]
      when ?: ; stack.concat [pop[]] * 2
      when ?\\ ; stack.concat [pop[], pop[]]
      when ?# ; move[]  # "adds the delta to the position"
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
      when ?~ ; if c = stdin.getc then stack << c.ord else reflect[] end
      when ?&
        getc = ->{ stdin.getc or (reflect[]; throw) }
        catch do
          nil until (?0..?9).include?(c = getc[])
          c << cc while (?0..?9).include?(cc = gets[])
          stack << c.to_i
        end
      when ?, ; stdout.print pop[].chr
      when ?. ; stdout.print "#{pop[]} "
      when ?! ; stack << (pop[].zero? ? 1 : 0)
      when ?` ; stack << (pop[]<pop[] ? 1 : 0)
      ### Funge-98 Final Specification:
      # A Funge-98 program should also be able to rely on the memory mechanism acting as
      # if a cell contains blank space (ASCII 32) if it is unallocated, and setting memory
      # to be full of blank space cells upon actual allocation (program load, or p instruction)
      when ?g
        y, x = pop[], pop[]
        stack << get[]
      when ?p
        y, x, v = pop[], pop[], pop[]
        code[oy + y] ||= []
        code[oy + y][ox + x] = v
      when ?@ ; return Struct.new(:stdout, :stack, :exitcode).new(stdout, stack, 0)

      ### 98
      when ?q ; return Struct.new(:stdout, :stack, :exitcode).new(stdout, stack, pop[])
      when ?a..?f ; stack << char - ?a.ord + 10
      when ?n ; stack.clear
      when ?'
        move[]
        stack << get[]
      when ?s
        move[]
        code[y + oy] ||= []
        code[y + oy][x + ox] = pop[]
      when ?[ ; dy, dx = ds[(ds.index([dy, dx]) - 1) % 4]
      when ?] ; dy, dx = ds[(ds.index([dy, dx]) + 1) % 4]
      when ?w ; dy, dx = ds[(ds.index([dy, dx]) + (pop[] > pop[] ? -1 : 1)) % 4]
      when ?r ; reflect[]
      when ?x ; dy, dx = [pop[], pop[]]
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
        fail if char != 32 || char.chr != ?;
        move[]
        char = get[]
      when ?{
        toss = if 0 > n = pop[]
          stack.concat [0] * -n
          []
        else
          stack.pop n
        end
        stack << ox << oy
        ox += x + dx
        oy += y + dy
        stacks << stack = toss
      when ?{
        if 1 == stacks.size
          reflect[]
        elsif 0 > n = pop[]
          stacks.pop
          stack = stacks.last
          oy, ox = pop[], pop[]
          stack.pop -n
        else
          t = stack.pop n
          stacks.pop
          stack = stacks.last
          oy, ox = pop[], pop[]
          stack.concat t
        end
      when ?u
        if 1 == stacks.size
          reflect[]
        elsif 0 > n = pop[]
          -n.times{ stack[-2] << pop[] }
        else
          n.times{ stack << stack[-2].pop }
        end
      when ?i
        fail "TODO"
        s = ""
        s << c.chr until (c = pop[]).zero?
        f = pop[]
        va = [pop[], pop[]]
        # ...
      when ?o
        fail "TODO"
        s = ""
        s << c.chr until (c = pop[]).zero?
        f = pop[]
        # y, x = pop[], pop[]
        # h, w = pop[], pop[]
        # ...
      when ?=
        s = ""
        s << c.chr until (c = pop[]).zero?
        system s, out: File::NULL, err: File::NULL
        stack << $?.exitstatus
      when ?(, ?)
        fail "TODO"
        # pop[].times.inject(0){ |i,| i * 256 + pop[] }
        # reflect[]
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
        stack << y << x
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
