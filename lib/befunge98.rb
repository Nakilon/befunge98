STDOUT.sync = true

def Befunge98 source, out = StringIO.new
  code = source.split ?\n

  stack = []
  pop = ->{ stack.pop || 0 }

  ds = [[0,1], [1,0], [-0,1], [-1,0]]
  dx, dy = 1, 0
  px, py = -1, 0
  go_west = ->{ dx, dy = -1, 0 }
  go_east = ->{ dx, dy = 1, 0 }
  go_north = ->{ dx, dy = 0, -1 }
  go_south = ->{ dx, dy = 0, 1 }
  move = lambda do
    (px += dx; px %= code[py].size) if dx != 0
    (py += dy; py %= code.size) if dy != 0
  end

  quotes = false
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
    next stack.push char.ord if quotes && char != ?"
    next unless (32..126) === char.ord
    case char
      ### 93
      when ?" ; quotes ^= true
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
      when ?& ; stack.push STDIN.gets.to_i
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
        code[y] = [] unless code[y]
        code[y][x] = v.chr
      when ?g
        y, x = pop[], pop[]
        stack.push ((code[y] || "")[x] || ?\s).ord
        # https://github.com/catseye/Funge-98/blob/master/doc/funge98.markdown
        # A Funge-98 program should also be able to rely on the memory mechanism acting as
        # if a cell contains blank space (ASCII 32) if it is unallocated, and setting memory
        # to be full of blank space cells upon actual allocation (program load, or p instruction)
      when ?@ ; return out, 0
      ### 98
      when ?q ; return out, pop[]
      when ?; ; jump_over ^= true
      when ?] ; dy, dx = ds[(ds.index([dy, dx]) + 1) % ds.size]
      when ?[ ; dy, dx = ds[(ds.index([dy, dx]) - 1) % ds.size]
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
    end
  end
end
