app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import cli.Stdout
import cli.File
import cli.Arg exposing [Arg]

main! : List Arg => Result {} _
main! = |_args|
    ### EXAMPLE INPUT
    ### READ INPUT
    lines =
        File.read_utf8!("input.txt")?
        |> Str.trim()
        |> Str.split_on("\n")

    ### PART 1

    when
        part1(lines)
    is
        Ok zeroes ->
            Stdout.line!("Part 1: ${Num.to_str(zeroes)}")?

        Err InvalidNumStr -> Stdout.line!("Invalid Number somewhere")?
        Err InvalidLine -> Stdout.line!("Invalid direction somewhere")?

    ### PART 2

    when part2(lines) is
        Ok num_zero_crossings ->
            Stdout.line!("Part 2: ${Num.to_str(num_zero_crossings)}")

        Err _ ->
            Stdout.line!("Invalid Example")

part1 : List Str -> Result I32 [InvalidNumStr, InvalidLine]
part1 = |input_lines|
    res =
        parse_lines(input_lines)?
        |> List.walk(
            (50, 0),
            |(acc, num_zeroes), elem|
                new_acc = step(acc, elem)
                (new_acc, num_zeroes + Num.to_i32(Num.from_bool(new_acc == 0))),
        )
    Ok res.1

part2 : List Str -> Result I32 [InvalidNumStr, InvalidLine]
part2 = |input_lines|
    res =
        parse_lines(input_lines)?
        |> List.walk(
            (50, 0),
            |(acc, num_zeroes), elem|
                (new_acc, num_zero_crossings) = step2(acc, elem)
                (new_acc, num_zeroes + num_zero_crossings),
        )
    Ok res.1

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
    res = current + rotation
    mod = res % 100
    mod
    + if mod < 0 then
        100
    else
        0

step2 : I32, I32 -> (I32, I32)
step2 = |current, rotation|
    added = current + rotation

    num_zero_crossings =
        if Num.is_negative(rotation) then
            # turn the effective subtraction
            # into something where can count the times
            # we hit zero with division by 100.0
            (
                if current == 0 then
                    # if we are at 0 we can simply count how often we hit -100.0 with rotation
                    rotation
                else
                    # if we become negative by applying the rotation
                    #
                    (current - 100) + rotation
            )
            |> Num.abs()
            |> Num.to_frac()
            |> Num.div 100.0
            |> Num.floor() # round up towards zero
        else
            # count how often we went from 99 -> 100 (which is 99 -> 0)
            added
            |> Num.to_frac()
            |> Num.div 100.0
            |> Num.floor() # round down towards zero
    mod = added % 100
    res = if Num.is_negative mod then
        mod + 100
    else
        mod
    (res, num_zero_crossings)

expect
    res = step2(0, 1)
    res == (1, 0)
expect
    res = step2(0, -1)
    res == (99, 0)
expect
    res = step2(0, -99)
    res == (1, 0)
expect
    res = step2(0, -100)
    res == (0, 1)
expect
    res = step2(0, 99)
    res == (99, 0)
expect
    res = step2(0, 100)
    res == (0, 1)
expect
    res = step2(50, -68)
    res == (82, 1)
expect
    res = step2(50, 1000)
    res == (50, 10)
expect
    res = step2(1, -1)
    res == (0, 1)
expect
    example_input =
        """
        L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82
        """
    example_lines = Str.split_on(Str.trim(example_input), "\n")
    res = part2(example_lines)
    res == Ok 6
expect
    example_input =
        """
        L50
        R10
        """
    example_lines = Str.split_on(Str.trim(example_input), "\n")
    res = part2(example_lines)
    res == Ok 1

