use ".."
use "collections"
use "debug"
use "format"
use "itertools"

primitive Priorities
  fun apply(char: U8): U64 =>
    U64.from[U8](
      if (char < 'a') then
        char - 38
      else
        char - 96
      end
    )

primitive Part1
  fun compartment_priority(line: String val): U64 ? =>
    let split_point = (line.size() / 2).isize()
    // firts sort both arrays
    let arr1: Array[U8] ref = Sort[Array[U8], U8](line.substring(0, split_point).iso_array())
    let arr2: Array[U8] ref = Sort[Array[U8], U8](line.substring(split_point).iso_array())

    // advance the iter with the smaller value until we find a match or
    // exhaust one of both
    let iter1 = arr1.values()
    let iter2 = arr2.values()

    var c1 = iter1.next()?
    var c2 = iter2.next()?
    let similar: U8 =
      while true do
        if (c1 < c2) and iter1.has_next() then
          c1 = iter1.next()?
        elseif c1 == c2 then
          break c1
        elseif iter2.has_next() then
          c2 = iter2.next()?
        else
          Debug(arr1)
          Debug(arr2)
          error
        end
      else
        U8.max_value()
      end

    let priority = Priorities(similar)
    //Debug(String.from_utf32(similar.u32()) + ": " + priority.string())
    priority


primitive Part2
  fun group_priority(group: Array[String val] ref): U64 ? =>
    // TODO: abstract away into function handlign an arbitrary array of
    // pre-sorted iters
    let iter1 = Sort[Array[U8], U8](group(0)?.array().clone()).values()
    let iter2 = Sort[Array[U8], U8](group(1)?.array().clone()).values()
    let iter3 = Sort[Array[U8], U8](group(2)?.array().clone()).values()

    var c1 = iter1.next()?
    var c2 = iter2.next()?
    var c3 = iter3.next()?

    let similar: U8 =
      while true do
        if (c1 == c2) and (c2 == c3) then
          break c1
        elseif ((c1 < c2) or (c1 < c3)) and iter1.has_next() then
          c1 = iter1.next()?
        elseif ((c2 < c1) or (c2 < c3)) and iter2.has_next() then
          c2 = iter2.next()?
        elseif ((c3 < c1) or (c3 < c2)) and iter3.has_next() then
          c3 = iter3.next()?
        else
          error
        end
      else
        U8.max_value() // shouldn't happen
      end

    let priority = Priorities(similar)
    //Debug(String.from_utf32(similar.u32()) + "(" + similar.string() + "): " + priority.string())
    priority


actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var group_sum = U64(0)
      var compartment_sum = U64(0)
      let group: Array[String val] ref = Array[String val](3)
      for line in lines do
        if line.size() == 0 then continue end
        let line_val = recover val (consume line) end
        // Part1
        compartment_sum = compartment_sum + Part1.compartment_priority(line_val)?

        // Part2
        group.push(line_val)
        if group.size() == 3 then
          let priority = Part2.group_priority(group)?
          group_sum = group_sum + priority
          group.clear()
        end
      end
      env.out.print("Part 1: " + compartment_sum.string())
      env.out.print("Part 2: " + group_sum.string())
    else
      env.exitcode(1)
    end
