app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import cli.Stdout
import cli.File
import cli.Arg exposing [Arg]

main! : List Arg => Result {} _
main! = |_args|
    # read input.txt into string
    # split into lines
    # parse each line into + = R, - = L distance -> number
    # -> List of ints
    # go from 50
    # current state: 50, line: -68
    str = File.read_utf8!("input.txt")?
    lines = Str.split_on(Str.trim(str), "\n")
    when
        parse_lines(lines)
    is
        Ok rotations ->
            res = List.walk(
                rotations,
                (50, 0),
                |(acc, num_zeroes), elem|
                    new_acc = step(acc, elem)
                    (new_acc, num_zeroes + if new_acc == 0 then 1 else 0),
            )
            Stdout.line!("ZEROES: ${Num.to_str(res.1)}")

        Err InvalidNumStr -> Stdout.line!("Invalid Number somewhere")
        Err InvalidLine -> Stdout.line!("Invalid direction somewhere")

parse_lines : List Str -> Result (List I32) [InvalidNumStr, InvalidLine]
parse_lines = |rotations|
    List.map_try(rotations, parse_rotation)

parse_rotation : Str -> Result I32 [InvalidNumStr, InvalidLine]
parse_rotation = |rotation|
    if Str.starts_with(rotation, "L") then
        dir = Str.to_i32(Str.drop_prefix(rotation, "L"))?
        Ok Num.to_i32(dir * -1)
    else if Str.starts_with(rotation, "R") then
        Ok Str.to_i32(Str.drop_prefix(rotation, "R"))?
    else
        return Err InvalidLine

step : I32, I32 -> I32
step = |current, rotation|
    if rotation > 0 then
        # R123
        next_state =
            when current is
                99 -> 0 # wrap around
                _ -> current + 1 # normal case
        step(next_state, rotation - 1)
    else if rotation < 0 then
        # L69
        next_state =
            when current is
                0 -> 99 # wrap around
                _ -> current - 1 # normal case
        step(next_state, rotation + 1)
    else
        current

