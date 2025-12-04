use ".."
use "collections"
use "debug"
use "files"
use "format"
use "itertools"

type AntinodeMap is Array[Array[U8] val] val

actor Solution is AocSolution
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 8

  fun get_map(input_file: String): AntinodeMap ? =>
    recover val
      Iter[String iso^](AOCUtils.get_input_lines(input_file, _env)?)
        .map[Array[U8] val]({(line) => recover val (consume line).iso_array() end})
        .collect(Array[Array[U8] val].create())
    end

  be part1(notify: SolutionNotify tag) =>
    try
      let map = get_map("2024/08/input.txt")?
      // populate antennas per frequency
      // TODO: this could be done in one pass over the map
      let antennas_per_freq = MapIs[U8, Array[U32]]
      // populate map bounds
      var max_y = USize(0)
      var max_x = USize(0)
      for (y, row) in map.pairs() do
        max_y = max_y.max(y)
        for (x, field) in row.pairs() do
          max_x = max_x.max(x)
          if field == '.' then
            continue
          else
            let position = (x.u32() << 16) or y.u32()
            antennas_per_freq.upsert(
              field,
              [position],
              {(current, provided) =>
                try current.push(provided.pop()?) end
                current
              })
          end
        end
      end
      let antinodes = Set[U32]
      for (freq, positions) in antennas_per_freq.pairs() do
        for posa in positions.values() do
          for posb in positions.values() do
            if posb == posa then
              continue
            end
            let x_a = (posa >> 16).u16()
            let y_a = posa.u16()

            let x_b = (posb >> 16).u16()
            let y_b = posb.u16()
            let diff_x = x_a - x_b
            let diff_y = y_a - y_b
            let antinode_x = x_a + diff_x
            let antinode_y = y_a + diff_y
            if (antinode_x <= max_x.u16()) and (antinode_y <= max_y.u16()) then
              let antinode_pos = (antinode_x.u32() << 16) or antinode_y.u32()
              antinodes.set(antinode_pos)
            end
          end
        end
      end
      //_env.out.write("   ")
      //for i in Range(0, max_x) do
      //  _env.out.write(i.string())
      //end
      //_env.out.print("")
      //for (y, row) in map.pairs() do
      //  _env.out.write(Format.int[USize](y where width=2, fill=' ') + " ")
      //  for (x, field) in row.pairs() do
      //    if field == '.' then
      //      _env.out.write(
      //        if antinodes.contains((x.u32() << 16) or y.u32()) then
      //          "#"
      //        else
      //          "."
      //        end
      //      )
      //    else
      //      _env.out.write(recover val String.>push(field) end)
      //    end
      //  end
      //  _env.out.print("")
      //end
      //for a in antinodes.values() do
      //  _env.out.print((a >> 16).u16().string() + ", " + a.u16().string())
      //end
      notify.done(this, 1, antinodes.size().string())

    else
      notify.fail(this, 1, "Error reading input")
    end


  be part2(notify: SolutionNotify tag) =>
    try
      let map = get_map("2024/08/input.txt")?
      // populate antennas per frequency
      let antennas_per_freq = MapIs[U8, Array[U32]]
      // populate map bounds
      var max_y = USize(0)
      var max_x = USize(0)
      for (y, row) in map.pairs() do
        max_y = max_y.max(y)
        for (x, field) in row.pairs() do
          max_x = max_x.max(x)
          if field == '.' then
            continue
          else
            let position = (x.u32() << 16) or y.u32()
            antennas_per_freq.upsert(
              field,
              [position],
              {(current, provided) =>
                try current.push(provided.pop()?) end
                current
              })
          end
        end
      end
      let antinodes = Set[U32]
      for (freq, positions) in antennas_per_freq.pairs() do
        for posa in positions.values() do
          for posb in positions.values() do
            if posb == posa then
              continue
            end
            antinodes.set(posa) // antennas themselves are antinodes
            let x_a = (posa >> 16).u16()
            let y_a = posa.u16()

            let x_b = (posb >> 16).u16()
            let y_b = posb.u16()
            let diff_x = x_a - x_b
            let diff_y = y_a - y_b
            var antinode_x = x_a + diff_x
            var antinode_y = y_a + diff_y

            while (antinode_x <= max_x.u16()) and (antinode_y <= max_y.u16()) do
              let antinode_pos = (antinode_x.u32() << 16) or antinode_y.u32()
              antinodes.set(antinode_pos)
              antinode_x = antinode_x + diff_x
              antinode_y = antinode_y + diff_y
            end
          end
        end
      end
      //_env.out.write("   ")
      //for i in Range(0, max_x) do
      //  _env.out.write(i.string())
      //end
      //_env.out.print("")
      //for (y, row) in map.pairs() do
      //  _env.out.write(Format.int[USize](y where width=2, fill=' ') + " ")
      //  for (x, field) in row.pairs() do
      //    if field == '.' then
      //      _env.out.write(
      //        if antinodes.contains((x.u32() << 16) or y.u32()) then
      //          "#"
      //        else
      //          "."
      //        end
      //      )
      //    else
      //      _env.out.write(recover val String.>push(field) end)
      //    end
      //  end
      //  _env.out.print("")
      //end
      //for a in antinodes.values() do
      //  _env.out.print((a >> 16).u16().string() + ", " + a.u16().string())
      //end
      notify.done(this, 2, antinodes.size().string())

    else
      notify.fail(this, 2, "Error reading input")
    end


