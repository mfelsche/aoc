use ".."
use "itertools"
use "collections"
use "debug"

actor Solution is AocSolution
  let _env: Env
  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 1

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

  be part1(notify: SolutionNotify) =>
    try
      (let left, let right) = this.get_input() ?
      let sorted_left = Sort[Array[U32], U32](consume left)
      let sorted_right = Sort[Array[U32], U32](consume right)
      let res = Iter[U32](sorted_left.values()).zip[U32](sorted_right.values()).map[U32]({(pair: (U32, U32)): U32 =>
        if pair._1 > pair._2 then
          pair._1 - pair._2
        else
          pair._2 - pair._1
        end
      }).fold[U32](0, {(acc: U32, distance: U32) => acc + distance}).string()
      notify.done(this, 1, consume res)
    else
      notify.fail(this, 1, "Error reading input")
    end


  be part2(notify: SolutionNotify) =>
    try
      (let left, let right) = this.get_input()?
      let counter_map = MapIs[U32, U32].create()

      for r in right.values() do
        counter_map.upsert(r, 1, {(current, provided) => current + provided})
      end

      var sum = U32(0)
      for l in left.values() do
        try
          let multiplier = counter_map(l)?
          sum = sum + (l * multiplier.u32())
        end
      end
      notify.done(this, 2, sum.string())
    else
      notify.fail(this, 2, "Error reading input")
    end

