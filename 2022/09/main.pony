use ".."
use "collections"

primitive Down
primitive Up
primitive Left
primitive Right

type Direction is (Down | Up | Left | Right)

class ref Knot
  var x: ISize = 0
  var y: ISize = 0

  new ref create() => None

  fun position(): Position =>
    Position(x, y)

  fun ref move(d: Direction) =>
    match d
    | Down  => y = y - 1
    | Up    => y = y + 1
    | Left  => x = x - 1
    | Right => x = x + 1
    end

  fun ref follow(k: Knot box) =>
    """
    Follow the other knot and try to get/stay adjacent to it
    """
    let x_diff = k.x - x
    let x_diff_abs = x_diff.abs().isize()
    let y_diff = k.y - y
    let y_diff_abs = y_diff.abs().isize()

    (let x_move, let y_move) =
      if x_diff_abs > 1 then
        let x_m = x_diff / x_diff_abs // clamp move to 1/-1

        let y_m =
          if y_diff_abs > 0 then
            // move diagonally
            y_diff / y_diff_abs
          else
            0
          end
        (x_m, y_m)
      elseif y_diff_abs > 1 then
        let y_m = y_diff / y_diff_abs // clamp move to 1/-1

        let x_m =
          if x_diff_abs > 0 then
            // move diagonally
            x_diff / x_diff_abs
          else
            0
          end
        (x_m, y_m)
      else
        (0, 0)
      end
    x = x + x_move
    y = y + y_move

class val Position is Equatable[Position]
  let _x: ISize
  let _y: ISize

  new val create(x: ISize, y: ISize) =>
    _x = x
    _y = y

  fun eq(that: box->Position): Bool =>
    (_x == that._x) and (_y == that._y)

  fun box hash(): USize val =>
    _x.hash() xor _y.hash()

  fun box string(): String iso^ =>
    recover iso String .> append("[") .> append(_x.string()) .> append(", ") .> append(_y.string()) .> append("]") end

class ref Bridge
  let rope: Array[Knot] ref
  let positions: Set[Position] = Set[Position]
  let head: Knot
  let tail: Knot

  new ref create(size: USize) ? =>
    rope = Array[Knot].create(size)
    for i in Range[USize](0, size, 1) do
      rope.push(Knot)
    end
    head = rope(0)?
    tail = rope(rope.size() - 1)?
    positions.set(tail.position())

  fun ref execute_move(dir: Direction) =>
    head.move(dir)
    var last = head
    for knot in rope.values() do
      knot.follow(last)
      last = knot
    end
    //env.out.print("head: " + head.position().string())
    //env.out.print("tail: " + tail.position().string())
    positions.set(tail.position())


actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?

      let part1 = Bridge(where size = 2)?
      let part2 = Bridge(where size = 10)?

      for line in lines do
        if line.size() == 0 then
          continue
        end

        let splitted = (consume line).split_by(" ")
        let dir =
          match splitted(0)?
          | "D" => Down
          | "U" => Up
          | "R" => Right
          | "L" => Left
          else
            error
          end
        var amount: USize = splitted(1)?.usize()?
        while amount > 0 do
          part1.execute_move(dir)
          part2.execute_move(dir)
          amount = amount - 1
        end
      end
      env.out.print("Part 1: " + part1.positions.size().string())
      env.out.print("Part 2: " + part2.positions.size().string())

    else
      env.exitcode(1)
    end


