"""
--- Day 6: Tuning Trouble ---

The preparations are finally complete; you and the Elves leave camp on foot and begin to make your way toward the star fruit grove.

As you move through the dense undergrowth, one of the Elves gives you a handheld device. He says that it has many fancy features, but the most important one to set up right now is the communication system.

However, because he's heard you have significant experience dealing with signal-based systems, he convinced the other Elves that it would be okay to give you their one malfunctioning device - surely you'll have no problem fixing it.

As if inspired by comedic timing, the device emits a few colorful sparks.

To be able to communicate with the Elves, the device needs to lock on to their signal. The signal is a series of seemingly-random characters that the device receives one at a time.

To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream. In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are all different.

The device will send your subroutine a datastream buffer (your puzzle input); your subroutine needs to identify the first position where the four most recently received characters were all different. Specifically, it needs to report the number of characters from the beginning of the buffer to the end of the first such four-character marker.

For example, suppose you receive the following datastream buffer:

mjqjpqmgbljsphdztnvjfqwrcgsmlb

After the first three characters (mjq) have been received, there haven't been enough characters received yet to find the marker. The first time a marker could occur is after the fourth character is received, making the most recent four characters mjqj. Because j is repeated, this isn't a marker.

The first time a marker appears is after the seventh character arrives. Once it does, the last four characters received are jpqm, which are all different. In this case, your subroutine should report the value 7, because the first start-of-packet marker is complete after 7 characters have been processed.

Here are a few more examples:

    bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 5
    nppdvjthqldpwncqszvftbrmjlhg: first marker after character 6
    nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 10
    zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 11

How many characters need to be processed before the first start-of-packet marker is detected?

--- Part Two ---

Your device's communication system is correctly detecting packets, but still isn't working. It looks like it also needs to look for messages.

A start-of-message marker is just like a start-of-packet marker, except it consists of 14 distinct characters rather than 4.

Here are the first positions of start-of-message markers for all of the above examples:

    mjqjpqmgbljsphdztnvjfqwrcgsmlb: first marker after character 19
    bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 23
    nppdvjthqldpwncqszvftbrmjlhg: first marker after character 23
    nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 29
    zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 26

How many characters need to be processed before the first start-of-message marker is detected?

"""
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

