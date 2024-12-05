use day1 = "01"
use day2 = "02"
use day3 = "03"

use "cli"
use "itertools"
use "pony_check"

actor Main
  new create(env: Env) =>
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

    let day: (U64 | None) = 
      match cmd.option("day").u64()
      | 0 => None // run all days
      | let other: U64 => other
      end


    let solutions: Array[AocSolution ref] ref = [
      // add new solution here
      day3.Solution(env)
      day2.Solution(env)
      day1.Solution(env)
    ]

    for solution in Poperator[AocSolution ref].create(solutions) do
      match day
      | None | solution.day() =>
        env.out.print("Running Day " + solution.day().string())
        try
          let output = solution.part1()?
          env.out.print("Part I:")
          env.out.print("")
          env.out.print(output)
          env.out.print("")
        else
          env.err.print("Error.")
          env.exitcode(1)
          return
        end
        try
          let output = solution.part2()?
          env.out.print("Part II:")
          env.out.print("")
          env.out.print(output)
          env.out.print("")
        else
          env.err.print("Error.")
          env.exitcode(1)
          return
        end
      end
    end


trait AocSolution
  new ref create(env: Env)

  fun tag day(): U64

  fun ref part1(): String?
  fun ref part2(): String?
