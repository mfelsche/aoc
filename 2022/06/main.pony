use ".."
use "collections"
use "itertools"
use "debug"

actor Main
  fun check_window(window: RingBuffer[U8] box, window_size: USize, env: Env): Bool ? =>
    if window.size() >= window_size then

      // check if we have no two same elements
      let set = SetIs[U8].create(window_size)
      let head = window.head()?

      var idx: USize = 0
      var set_size: USize = set.size()
      env.out.print("")
      while idx < window_size do
        let elem = window(head + idx)?
        env.out.write(String.from_utf32(elem.u32()) + ",")
        set.set(elem)
        if set.size() == set_size then
          // set did not grow, we found a duplicate
          return false
        end
        set_size = set.size()
        idx = idx + 1
      end
      // set did always grow, no dups
      true
    else
      // window not full yet
      false
    end

  new create(env: Env) =>
    try
      let signal = AOCUtils.get_input_lines("input.txt", env)?.next()?
      let part1_window = RingBuffer[U8].create(4)
      let part2_window = RingBuffer[U8].create(14)
      var window1_done = false
      for (i, byte) in Iter[U8]((consume signal).values()).enum() do
        if not window1_done then
          part1_window.push(byte)
          if check_window(part1_window, 4, env)? then
            window1_done = true
            env.out.print("Part 1: " + (i + 1).string())
          end
        end
        part2_window.push(byte)
        if check_window(part2_window, 14, env)? then
          // -1 in order to account for part2_window being actually having space for 16, nasty ringbuffer
          env.out.print("Part 2: " + (i - 1).string())
          break
        end
      end
    else
      env.exitcode(1)
    end

