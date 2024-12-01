use ".."
use "itertools"

class val Assignment
  let _min: U32
  let _max: U32

  new val create(s: String val) ? =>
    """
    parse input string into assigment range
    """
    let splitted = s.split_by("-", 2)
    _min = splitted(0)?.u32()?
    _max = splitted(1)?.u32()?

  fun box contains(other: Assignment): Bool =>
    (other._min >= _min) and (other._max <= _max)

  fun box is_inside(num: U32): Bool =>
    //TODO: support inclusive/exclusive bounds
    (_min <= num) and (num <= _max)

  fun box overlaps_with(other: Assignment): Bool =>
    is_inside(other._min) or is_inside(other._max)

actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var contains_sum: U32 = 0
      var overlaps_sum: U32 = 0
      for line in lines do
        if line.size() == 0 then continue end
        let pair = line.split_by(",", 2)
        let a1 = Assignment(pair(0)?)?
        let a2 = Assignment(pair(1)?)?
        if a1.contains(a2) or a2.contains(a1) then
          contains_sum = contains_sum + 1
          // containment is already an overlap
          overlaps_sum = overlaps_sum + 1
        elseif a1.overlaps_with(a2) then
          // we only need to check the containment cases
          // if we have no overlap, so check in 1 direction is enough
          overlaps_sum = overlaps_sum + 1
        end
      end
      env.out.print("Containing pairs: " + contains_sum.string())
      env.out.print("Overlapping pairs: " + overlaps_sum.string())
    else
      env.exitcode(1)
    end

