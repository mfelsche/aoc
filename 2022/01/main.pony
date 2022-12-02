"""
AOC 2022 puzzle 1

Part 1:
Find the Elf carrying the most Calories. How many total Calories is that Elf carrying?

Part 2:
Find the top three Elves carrying the most Calories. How many Calories are those Elves carrying in total?
"""
use @pony_os_errno[I32]()
use "files"
use "collections"
use "itertools"
use "debug"


// stolen from https://github.com/salty-blue-mango/roaring-pony
primitive BinarySearch
  fun reverse[T: Comparable[T] #read](needle: T, haystack: ReadSeq[T]): (USize, Bool) =>
    """
    Perform a binary search for `needle` on `haystack`.

    Returns the result as a 2-tuple of either:
    * the index of the found element and `true` if the search was successful, or
    * the index where to insert the `needle` to maintain a sorted `haystack` and `false`
    """
    try
      var i = USize(0)
      var l = USize(0)
      var r = haystack.size()
      var idx_adjustment: USize = 0
      while l < r do
        i = (l + r).fld(2)
        let elem = haystack(i)?
        match needle.compare(elem)
        | Greater =>
          idx_adjustment = 0
          r = i
        | Equal => return (i, true)
        | Less =>
          // insert index needs to be adjusted by 1 if greater
          idx_adjustment = 1
          l = i + 1
        end
      end
      (i + idx_adjustment, false)
    else
      // shouldnt happen
      Debug("invalid haystack access.")
      (0, false)
    end

class Max3ElfAcc
  let max3: Array[U64] = Array[U64].create(3)
  var current_elf_calories: U64 = 0

  fun ref update_elf_calories(by: U64) =>
    current_elf_calories = current_elf_calories + by

  fun ref finish_elf()? =>
    if max3.size() == 0 then
      max3.push(current_elf_calories)
    else
      (let idx, let _) = BinarySearch.reverse[U64](current_elf_calories, max3)
      max3.insert(idx, current_elf_calories)?
      max3.truncate(3)
    end
    current_elf_calories = 0


actor Main
  fun get_input_file(env: Env): File ? =>
    if env.args.size() < 2 then
      error
    else
      let file_auth = FileAuth(env.root)
      let path = FilePath(file_auth, env.args(env.args.size() - 1)?, recover val FileCaps .> all() end )
      match OpenFile(path)
      | let file: File =>
        file
      | let _: FileEOF =>
        env.err.print("EOF")
        error
      | let _: FileOK =>
        env.err.print("OK") // weird
        error
      | let _: FileError =>
        env.err.print("Error: " + @pony_os_errno().string())
        error
      | let _: FileBadFileNumber =>
        env.err.print("Bad file number")
        error
      | let _: FileExists =>
        env.err.print("Exists")
        error
      | let _: FilePermissionDenied =>
        env.err.print("Permission denied")
        error
      end
    end

  new create(env: Env) =>
    try
      let file = get_input_file(env)?
      let elf_acc: Max3ElfAcc = Iter[String iso^](file.lines()).fold_partial[Max3ElfAcc](
        Max3ElfAcc,
        object
          fun apply(acc: Max3ElfAcc, line: String iso): Max3ElfAcc^ ? =>
            if line.size() == 0 then
              acc.finish_elf()?
            else
              line.strip()
              let calories = line.u64()?
              acc.update_elf_calories(calories)
            end
            consume acc
        end
      )?
      env.out.print("Max calories: " + elf_acc.max3(0)?.string())
      env.out.print("Top 3 Max calories: " + Iter[U64](elf_acc.max3.values()).fold[U64](0, {(acc, c) => acc + c}).string())

    else
      env.err.print("Error calculating the top 3 max calories Elfs ")
      env.exitcode(1)
    end


