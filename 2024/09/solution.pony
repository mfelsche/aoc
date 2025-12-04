use ".."
use "collections"
use "debug"
use "files"
use "itertools"

actor Solution is AocSolution
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 9

  be part1(notify: SolutionNotify tag) =>
    try
      let input = AOCUtils.get_input("2024/09/input.txt", _env)?
      let line = recover ref (consume input).iso_array() end
      Debug(String .> append(line))
      
      // checksum method
      // when hitting the first hole - take as much of the last file as the hole
      // takes, decrementing the last file
      var result = U64(0)

      // ignore first file
      var position = (line(0)? - '0').usize()
      var right_file_idx = if (line.size() % 2) == 0 then USize(line.size() - 2) else USize(line.size() - 1) end

      for left_idx in Range[USize](1, line.size()) do
        if (left_idx % 2) == 0 then
          // we have a file
          let file_id = left_idx / 2
          var file_size: U8 = line(left_idx)? - '0'
          if file_size > 9 then
            notify.fail(this, 1, recover iso "File size = " + file_size.string() + " @ " + left_idx.string() end)
            return
          end
          // iterate through virtual file blocks
          while file_size > 0 do
            result = result + (file_id * position).u64()

            file_size = file_size - 1
            position = position + 1
          end
        elseif left_idx < right_file_idx then
          // we have a free space
          var file_id = right_file_idx / 2
          var right_file: U8 = (line(right_file_idx)? - '0')
          if right_file > 0 then
            var left_hole: U8 = (line(left_idx)? - '0')

            while left_hole > 0 do
              result = result + (file_id * position).u64()
              right_file = right_file - 1
              if right_file == 0 then
                // if left free space is bigger than right file, we gotta go to
                // the next file
                line(right_file_idx)? = '0'
                right_file_idx = right_file_idx -2
                file_id = right_file_idx / 2
                right_file = line(right_file_idx)? - '0'
                if left_idx > right_file_idx then
                  break
                end
              end
              left_hole = left_hole - 1
              position = position + 1
            end
            // update right_file
            line(right_file_idx)? = (right_file + '0')
          end
          if right_file == 0 then
            right_file_idx = right_file_idx - 2
          end
        end
      end
      notify.done(this, 1, result.string())
    else
      notify.fail(this, 1, "Error reading input")
    end


  be part2(notify: SolutionNotify tag) =>
    try
      let input = AOCUtils.get_input("2024/09/input.txt", _env)?
      let line = recover ref (consume input).iso_array() end
      Debug(String .> append(line))

      var result = U64(0)

      // ignore first file
      var position = (line(0)? - '0').usize()
      var right_file_idx = if (line.size() % 2) == 0 then USize(line.size() - 2) else USize(line.size() - 1) end
      // checksum method:
      // when hitting a free space, go backwards through the files and pick the
      // first file that fits the hole, count its file_id, then set its size to 0
      //
      var rightmost_unconsumed_file: USize = right_file_idx

      // populate all indices of leftmost holes for each possible size
      // in the worst case this is one pass over the whole array
      let leftmost_hole_indices: Array[USize] ref = Array[USize].init(-1, 8)
      var num_set = USize(0)
      for i in Range[USize](1, line.size() where step = 2) do
        let hole_size = (line(i)? - '0').usize()
        if leftmost_hole_indices(hole_size)? == -1 then
          // fill all smaller indices
          // because we later want to ask with a simple array indexing op for
          // the leftmost index
          for idx in Reverse[USize](hole_size, 0) do
            leftmost_hole_indices(idx)? = leftmost_hole_indices(idx)?.min(i)
          end
          num_set = num_set + 1
          if num_set == 9 then
            break
          end
        end
      end
      
      for left_idx in Range[USize](1, line.size()) do
        if (left_idx % 2) == 0 then
          // we have a file
          let file_id = left_idx / 2
          var file_size: U8 = line(left_idx)? - '0'
          if file_size > 9 then
            notify.fail(this, 1, recover iso "File size = " + file_size.string() + " @ " + left_idx.string() end)
            return
          end
          // iterate through virtual file blocks
          while file_size > 0 do
            result = result + (file_id * position).u64()

            file_size = file_size - 1
            position = position + 1
          end
        else //if left_idx < right_file_idx then
          // we have a free space
          var file_id = right_file_idx / 2
          var right_file: U8 = (line(right_file_idx)? - '0')
          var left_hole: U8 = (line(left_idx)? - '0')
          
          if right_file > 0 then
            while left_hole > right_file do
              right_file_idx = right_file_idx - 2
              right_file = (line(right_file_idx)? - '0')
            end
            // we have a fitting file
            // overwrite the old position
            line(right_file_idx)? = '0'
            

            while left_hole > 0 do
              result = result + (file_id * position).u64()
              right_file = right_file - 1
              if right_file == 0 then
                // if left free space is bigger than right file, we gotta go to
                // the next file
                line(right_file_idx)? = '0'
                right_file_idx = right_file_idx -2
                file_id = right_file_idx / 2
                right_file = line(right_file_idx)? - '0'
                if left_idx > right_file_idx then
                  break
                end
              end
              left_hole = left_hole - 1
              position = position + 1
            end
            // update right_file
            line(right_file_idx)? = (right_file + '0')
          end
          if right_file == 0 then
            right_file_idx = right_file_idx - 2
          end
        end
      end
      notify.done(this, 2 result.string())
    else
      notify.fail(this, 2, "Error reading input")
    end

