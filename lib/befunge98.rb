STDOUT.sync = true

def Befunge98 source, out = StringIO.new
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
    # TODO make a test about a potential when these lines were reversed?
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
    next stack.push char.ord if stringmode && char != ?"
    next unless (32..126) === char.ord
    case char
      ### 93
      when ?" ; stringmode ^= true
      when ?# ; move[]
      when ?> ; go_east[]
      when ?< ; go_west[]
      when ?^ ; go_north[]
      when ?v ; go_south[]
      when ?? ; [go_east, go_west, go_north, go_south].sample[]
      when ?| ; pop[].zero? ? go_south[] : go_north[]
      when ?_ ; pop[].zero? ? go_east[] : go_west[]
      when ?0..?9 ; stack.push char.to_i
      when ?$ ; pop[]
      when ?: ; stack.concat [pop[]]*2
      when ?\\ ; stack.push pop[], pop[]
      when ?~ ; stack.push (STDIN.getc || 0).ord
      when ?&
        stack.push STDIN.gets.to_i
        # TODO: Decimal input reads and discards characters until it encounters decimal digit characters,
        #       at which point it reads a decimal number from those digits, up until (but not including)
        #       the point at which input characters stop being digits, or the point where
        #       the next digit would cause a cell overflow, whichever comes first.
      when ?, ; out.print pop[].chr
      when ?. ; out.print ("%d\x0a" % pop[])
      when ?- ; stack.push -(pop[] - pop[])
      when ?+ ; stack.push (pop[] + pop[])
      when ?* ; stack.push (pop[] * pop[])
      when ?/ ; stack.push ((_ = pop[]; pop[] / _))
      when ?% ; stack.push ((_ = pop[]; pop[] % _))
      when ?` ; stack.push (pop[] < pop[] ? 1 : 0)
      when ?! ; stack.push (pop[].zero? ? 1 : 0)
      when ?p
        y, x, v = pop[], pop[], pop[]
        code[oy + y] = "" unless code[y]
        code[oy + y][ox + x] = v.chr
      when ?g
        y, x = pop[], pop[]
        stack.push ((code[oy + y] || "")[ox + x] || ?\s).ord
        # https://github.com/catseye/Funge-98/blob/master/doc/funge98.markdown
        # A Funge-98 program should also be able to rely on the memory mechanism acting as
        # if a cell contains blank space (ASCII 32) if it is unallocated, and setting memory
        # to be full of blank space cells upon actual allocation (program load, or p instruction)
      when ?@ ; return out, 0
      ### 98
      when ?q ; return out, pop[]
      when ?a..?f ; stack.push char.ord - ?a.ord + 10
      when ?n ; stack.clear
      when ?'
        move[]
        stack.push ((code[y] || "")[x] || ?\s).ord
      when ?s
        move[]
        code[py] = "" unless code[py]
        code[py][px] = pop[].chr
      when ?; ; jump_over ^= true
      when ?] ; dy, dx = ds[(ds.index([dy, dx]) + 1) % ds.size]
      when ?[ ; dy, dx = ds[(ds.index([dy, dx]) - 1) % ds.size]
      when ?w ; dy, dx = ds[(ds.index([dy, dx]) + (pop[] > pop[] ? -1 : 1)) % ds.size]
      when ?r ; dy, dx = [-dy, dx]
      when ?x ; dy, dx = [pop[], pop[]]
      when ?j
        if 0 < t = pop[]
          t.times{ move[] }
        else
          dy, dx = [-dy, dx]
          t.times{ move[] }
          dy, dx = [-dy, dx]
        end
      when ?k
        iterate = pop[]
        begin
          move[]
          char = (code[py] || "")[px] || ?\s
        end until char != ?\s || char != ?;
      when ?{
        # stacks.push toss = if 0 > n = pop[]
        #   Array.new(-n, 0)
        # else
        #   Array.new(n){ pop[] }
        # end
        n = pop[]
        toss = Array.new n unless toss = stack[stack.size-n..stack.size]
        stack << ox << oy
        ox = px + dx
        oy = py + dy
        stacks.push stack = toss
      when ?{
        if 1 == stacks.size
          dy, dx = [-dy, dx]
        else
          toss = stack
          t = (0 < n = pop[]) ? stack.last(n) : []
          stack = stacks.tap(&:pop).last
          oy, ox = pop[], pop[]
          stack.concat t
        end
      when ?u
        if 1 == stacks.size
          dy, dx = [-dy, dx]
        elsif 0 < n = pop[]
          n.times{ stack.push stack[1].pop }
        else
          n.times{ stack[1].push pop[] }
        end
    end
  end
end
