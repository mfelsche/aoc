use "files"
use "collections"
use "itertools"
use "debug"
use ".."


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

  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      let elf_acc: Max3ElfAcc = Iter[String iso^](lines).fold_partial[Max3ElfAcc](
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


