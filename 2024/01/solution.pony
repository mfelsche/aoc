"""
There's just one problem: by holding the two lists up side by side (your puzzle input), it quickly becomes clear that the lists aren't very similar. Maybe you can help The Historians reconcile their lists?

For example:

3   4
4   3
2   5
1   3
3   9
3   3

Maybe the lists are only off by a small amount! To find out, pair up the numbers and measure how far apart they are. Pair up the smallest number in the left list with the smallest number in the right list, then the second-smallest left number with the second-smallest right number, and so on.

Within each pair, figure out how far apart the two numbers are; you'll need to add up all of those distances. For example, if you pair up a 3 from the left list with a 7 from the right list, the distance apart is 4; if you pair up a 9 with a 3, the distance apart is 6.

In the example list above, the pairs and distances would be as follows:

    The smallest number in the left list is 1, and the smallest number in the right list is 3. The distance between them is 2.
    The second-smallest number in the left list is 2, and the second-smallest number in the right list is another 3. The distance between them is 1.
    The third-smallest number in both lists is 3, so the distance between them is 0.
    The next numbers to pair up are 3 and 4, a distance of 1.
    The fifth-smallest numbers in each list are 3 and 5, a distance of 2.
    Finally, the largest number in the left list is 4, while the largest number in the right list is 9; these are a distance 5 apart.

To find the total distance between the left list and the right list, add up the distances between all of the pairs you found. In the example above, this is 2 + 1 + 0 + 1 + 2 + 5, a total distance of 11!

Your actual left and right lists contain many location IDs. What is the total distance between your lists?
"""

use ".."
use "itertools"
use "collections"
use "debug"

class Solution is AocSolution
  let _env: Env
  new create(env: Env) =>
    _env = env

  fun tag day(): U64 => 1
  fun tag year(): U64 => 2024

  fun ref get_input(): (Array[U32], Array[U32]) ? =>
    let left: Array[U32] ref = Array[U32].create(64)
    let right: Array[U32] ref = Array[U32].create(64)

    let lines = AOCUtils.get_input_lines("2024/01/input.txt", _env)?
    for line in lines do
      var idx = 
        try
          line.find(" ")?.usize()
        else
          // most likely last empty line
          continue
        end
      left.push(line.substring(0, idx.isize()).u32()?)
      var c = line(idx)?
      while c == ' ' do
        idx = idx + 1
        c = line(idx)?
      end
      right.push(line.substring(idx.isize(), line.size().isize()).u32()?)
    end
    (left, right)

  fun ref part1(): String iso^ ? =>
    (let left, let right) = this.get_input() ?
    let sorted_left = Sort[Array[U32], U32](consume left)
    let sorted_right = Sort[Array[U32], U32](consume right)
    Iter[U32](sorted_left.values()).zip[U32](sorted_right.values()).map[U32]({(pair: (U32, U32)): U32 =>
      if pair._1 > pair._2 then
        pair._1 - pair._2
      else
        pair._2 - pair._1
      end
    }).fold[U32](0, {(acc: U32, distance: U32) => acc + distance}).string()

  fun ref part2(): String iso^ ? =>
    """
    --- Part Two ---

    Your analysis only confirmed what everyone feared: the two lists of location IDs are indeed very different.

    Or are they?

    The Historians can't agree on which group made the mistakes or how to read most of the Chief's handwriting, but in the commotion you notice an interesting detail: 
    a lot of location IDs appear in both lists! Maybe the other numbers aren't location IDs at all but rather misinterpreted handwriting.

    This time, you'll need to figure out exactly how often each number from the left list appears in the right list.
    Calculate a total similarity score by adding up each number in the left list after multiplying it by the number of times that number appears in the right list.

    Here are the same example lists again:

    3   4
    4   3
    2   5
    1   3
    3   9
    3   3

    For these example lists, here is the process of finding the similarity score:

        The first number in the left list is 3. It appears in the right list three times, so the similarity score increases by 3 * 3 = 9.
        The second number in the left list is 4. It appears in the right list once, so the similarity score increases by 4 * 1 = 4.
        The third number in the left list is 2. It does not appear in the right list, so the similarity score does not increase (2 * 0 = 0).
        The fourth number, 1, also does not appear in the right list.
        The fifth number, 3, appears in the right list three times; the similarity score increases by 9.
        The last number, 3, appears in the right list three times; the similarity score again increases by 9.

    So, for these example lists, the similarity score at the end of this process is 31 (9 + 4 + 0 + 0 + 9 + 9).

    Once again consider your left and right lists. What is their similarity score?
    """
    (let left, let right) = this.get_input()?
    let counter_map = Array[U16].init(0, 100000)

    var num_similar = U16(0)
    var previous = U32.min_value()

    for i in Sort[Array[U32], U32](consume right).values() do
      if i > previous then
        if num_similar > 0 then
          // write out num-similar into the counter map
          if previous.usize() > counter_map.space() then
            counter_map.reserve(i.usize()) // :(((
          end
          counter_map(previous.usize())? = num_similar
        end
        num_similar = 1
      elseif i == previous then
        // inc
        num_similar = num_similar + 1
      end
      previous = i
    end
    // ensure the last number has been calculated
    if num_similar > 0 then
      if previous.usize() > counter_map.space() then
        counter_map.reserve(previous.usize()) // :(((
      end
      counter_map(previous.usize())? = num_similar
    end

    var sum = U32(0)
    for l in left.values() do
        try
          let multiplier = counter_map(l.usize())?
          if multiplier > 0 then
            sum = sum + (l * multiplier.u32())
          end
        end
    end
    sum.string()

