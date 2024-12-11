use day1 = "01"
use day2 = "02"
use day3 = "03"
use day4 = "04"
use day5 = "05"
use day6 = "06"
use day7 = "07"

use "cli"
use "itertools"
use "pony_check"

actor Main

  var _days_started: USize = 0
  let _env: Env

  new create(env: Env) =>
    _env = env
    let cs =
      try
        CommandSpec.leaf("aoc", "An AOC runner", [
          OptionSpec.u64("day", "Run the program of the given day"
            where short' = 'd', default' = 0
          )
        ], [
        ])? .> add_help()?
      else
        env.exitcode(-1)  // some kind of coding error
        return
      end

    let cmd =
      match CommandParser(cs).parse(env.args, env.vars)
      | let c: Command => c
      | let ch: CommandHelp =>
          ch.print_help(env.out)
          env.exitcode(0)
          return
      | let se: SyntaxError =>
          env.err.print(se.string())
          env.exitcode(1)
          return
      end

    let day: (U32 | None) =
      match cmd.option("day").u64().u32()
      | 0 => None // run all days
      | let other: U32 => other
      end


    let solutions: Array[AocSolution tag] ref = [
      // add new solution here
      day7.Solution(env)
      day6.Solution(env)
      day5.Solution(env)
      day4.Solution(env)
      day3.Solution(env)
      day2.Solution(env)
      day1.Solution(env)
    ]

    for solution in Poperator[AocSolution tag].create(solutions) do
      match day
      | None | solution.day() =>
        _days_started = _days_started + 1
        env.out.print("Running Day " + solution.day().string())
        solution.part1(recover tag this end)
      end
    end

  be done(solution: AocSolution, part: U32, output: String iso) =>
    _env.out.print(
      "Day " + solution.day().string() + "\n" +
      "Part " + part.string() + "\n" +
      consume output + "\n"
    )
    if part == 1 then
      solution.part2(recover tag this end)
    end

  be fail(solution: AocSolution, part: U32, err: String val) =>
    _env.out.print(
      "Day " + solution.day().string() + "\n" +
      "Part " + part.string() + "\n" +
      "Error: " + err + "\n"
    )
    _env.exitcode(1)


interface tag AocSolution
  new tag create(env: Env)
  fun tag day(): U32

  be part1(notify: SolutionNotify tag)
  be part2(notify: SolutionNotify tag)

interface tag SolutionNotify
  be done(solution: AocSolution, part: U32, output: String iso)
  be fail(solution: AocSolution, part: U32, err: String val)


