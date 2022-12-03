"""

# Part 1
## Mapping

Opponent: A for Rock, B for Paper, and C for Scissors
You: X for Rock, Y for Paper, and Z for Scissors

## Scoring

Total score sum of scores for each round

Shape played score:

Rock: 1
Paper: 2
Scissors: 3

Outcome score:

Loss: 0
Draw: 3
Win: 6

## Task

What would your total score be if everything goes exactly according to your strategy guide (input)?

# Part 2

## Mapping

Opponent: A for Rock, B for Paper, and C for Scissors
Outcome: X for Loss, Y for Draw, Z means Win

## Task

what would your total score be if everything goes exactly according to your strategy guide?

"""
use ".."
use "debug"

primitive Rock
  fun score(): U32 => 1
  fun string(): String val => "Rock"
primitive Paper
  fun score(): U32 => 2
  fun string(): String val => "Paper"
primitive Scissors
  fun score(): U32 => 3
  fun string(): String val => "Scissors"

type Shape is ( Rock | Paper | Scissors )

primitive Shapes
  fun from_char(char: U8): Shape ? =>
    match char
    | U8('A') | U8('X') => Rock
    | U8('B') | U8('Y') => Paper
    | U8('C') | U8('Z') => Scissors
    else
      Debug("Invalid char: " + char.string())
      error
    end

  fun chose_for_outcome(opponent: Shape, outcome: Outcome): Shape =>
    match (opponent, outcome)
    | (Rock, Win)  | (Paper, Draw) | (Scissors, Loss) => Paper
    | (Rock, Loss) | (Paper, Win)  | (Scissors, Draw) => Scissors
    | (Rock, Draw) | (Paper, Loss) | (Scissors, Win) => Rock
    else
      // shouldn't happen
      Rock
    end

primitive Win
  fun score(): U32 => 6
  fun string(): String val => "Win"
primitive Draw
  fun score(): U32 => 3
  fun string(): String val => "Draw"
primitive Loss
  fun score(): U32 => 0
  fun string(): String val => "Loss"
type Outcome is ( Win | Draw | Loss )

primitive Outcomes
  fun from_char(char: U8): Outcome ? =>
    match char
    | U8('X') => Loss
    | U8('Y') => Draw
    | U8('Z') => Win
    else
      error
    end

primitive Round
  fun score(me: Shape, opponent: Shape): U32 =>
    let outcome: Outcome =
      match (me, opponent)
      | (Rock, Paper)    | (Paper, Scissors) | (Scissors, Rock) => Loss
      | (Rock, Scissors) | (Paper, Rock)     | (Scissors, Paper) => Win
      else
        Draw
      end
    let round_score = outcome.score() + me.score()
    //Debug(opponent.string() + " vs " + me.string() + " => " + outcome.string() + " == " + round_score.string())
    round_score

actor Main
  fun calculate_part1_score(opponent: String, me: String): U32 ? =>
    """
    Both elements interpreted as shapes
    """
    let o_shape = Shapes.from_char(opponent(0)?)?
    let me_shape = Shapes.from_char(me(0)?)?
    Round.score(me_shape, o_shape)

  fun calculate_part2_score(opponent: String, outcome: String): U32 ? =>
    let o_shape = Shapes.from_char(opponent(0)?)?
    let expected_outcome = Outcomes.from_char(outcome(0)?)?
    let me_shape = Shapes.chose_for_outcome(o_shape, expected_outcome)
    Round.score(me_shape, o_shape)

  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var part1_score: U32 = 0
      var part2_score: U32 = 0
      var rounds: U32 = 0
      for line in lines do
        let linev: String val = consume line
        if linev.size() == 0 then
          break
        end

        try
          let shapes = linev.split_by(" ", 2)
          part1_score = part1_score + calculate_part1_score(shapes(0)?, shapes(1)?)?
          part2_score = part2_score + calculate_part2_score(shapes(0)?, shapes(1)?)?
          rounds = rounds + 1
        else
          Debug("Error")
        end
      end
      env.out.print("Rounds: " + rounds.string())
      env.out.print("")
      env.out.print("=== PART 1 ===")
      env.out.print("Total score: " + part1_score.string())
      env.out.print("=== PART 2 ===")
      env.out.print("Total score: " + part2_score.string())

    else
      env.err.print("Error")
      env.exitcode(1)
    end
