use ".."
use "itertools"
use "collections"
use "debug"

actor Solution is AocSolution
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 2

  fun ref get_input(file_path: String): Iterator[Array[I32]] ? =>
    Iter[String](AOCUtils.get_input_lines(file_path, _env)?).map[Array[I32]]({(line: String) =>
        Iter[String](line.split(" ").values())
          .filter_map[I32]({(level) => try level.i32()? end})
          .collect(Array[I32].create(10))
    })
  
  fun signum[T: (Integer[T] & Signed)](num: T): T =>
    if num > T.from[I8](0) then 
      T.from[I8](1)
    elseif num < T.from[I8](0) then
      T.from[I8](-1)
    else
      T.from[I8](0)
    end

  be part1(notify: SolutionNotify) =>
    var num_safe: USize = 0
    try
      for levels in get_input("2024/02/input.txt")? do
        var safe: Bool = true
        var previous_direction: (I32 | None) = None
        var previous_level: (I32 | None) = None

        for level in levels.values() do
          match previous_level
          | let prev: I32 =>
            let diff = prev - level
            let abs_diff = diff.abs()
            let direction = signum[I32](diff)
            let cur_safe = 
              (1 <= abs_diff) and (abs_diff <= 3)
              and
              try
                previous_direction as I32 == direction
              else
                true // first comparison
              end
            previous_direction = direction
            if not cur_safe then
              safe = false
              break
            end
          end
          previous_level = level
        end
        if safe then
          num_safe = num_safe + 1
        end
      end
      notify.done(this, 1, num_safe.string())
    else
      notify.fail(this, 1, "Error reading file")
    end


  be part2(notify: SolutionNotify) =>
    var num_safe: USize = 0
    try
      for levels in get_input("2024/02/input.txt")? do
        for remove_idx in Range[USize](0, levels.size()) do
          var safe: Bool = true
          var previous_direction: (I32 | None) = None
          var previous_level: (I32 | None) = None

          for (idx, level) in levels.pairs() do
            if idx == remove_idx then
              continue
            end

            match previous_level
            | let prev: I32 =>
              let diff = prev - level
              let abs_diff = diff.abs()
              let direction = signum[I32](diff)
              let cur_safe = 
                (1 <= abs_diff) and (abs_diff <= 3)
                and
                try
                  previous_direction as I32 == direction
                else
                  true // first comparison
                end
              previous_direction = direction
              if not cur_safe then
                safe = false
                break // stop processing with this remove_idx, we are not safe
              end
            end
            previous_level = level
          end

          if safe then
            //Debug(levels)
            //Debug("safe when removing " + levels(remove_idx)?.string())
            num_safe = num_safe + 1
            break // break out iterating over remove_indices
          end
        end
      end
      notify.done(this, 2, num_safe.string())
    else
      notify.fail(this, 2, "Error reading input")
    end



