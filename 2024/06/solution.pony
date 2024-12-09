use ".."
use "collections"
use "debug"
use "files"
use "itertools"

primitive MapFields
  fun guard(): U8 => '^'
  fun obstacle(): U8 => '#'
  fun free(): U8 => '.'

type Direction is (Up | Right | Down | Left)

primitive Up is Equatable[Direction]
  fun move(): (ISize, ISize) => (0, -1)
  fun turn(): Direction => Right
  fun hash(): USize => 1
primitive Right is Equatable[Direction]
  fun move(): (ISize, ISize) => (1, 0)
  fun turn(): Direction => Down
  fun hash(): USize => 2
primitive Down is Equatable[Direction]
  fun move(): (ISize, ISize) => (0, 1)
  fun turn(): Direction => Left
  fun hash(): USize => 3
primitive Left is Equatable[Direction]
  fun move(): (ISize, ISize) => (-1, 0)
  fun turn(): Direction => Up
  fun hash(): USize => 4
  

actor Solution is AocSolution
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 6

  be part1(notify: SolutionNotify tag) =>
    try
      let map = build_map("2024/06/input.txt")?
      match find_guard(map)
      | let guard: Guard =>
        let visited_positions = Set[Pos].create()
        visited_positions.set(guard.pos) // store start position
        Debug("guard @ " + guard.pos.string())
        while true do
          let next_pos = guard.next_pos()
          try
            let next_field = map(next_pos.y)?(next_pos.x)?
            if next_field == MapFields.obstacle() then
              guard.turn()
            else
              visited_positions.set(next_pos)
              guard.move()
            end
          else
            // guard left the map
            //Debug("guard left the map @ " + guard.pos.string())
            notify.done(this, 1, visited_positions.size().string())
            return
          end
        end
      | None =>
        notify.fail(this, 1, "Guard not found")
      end
    else
      notify.fail(this, 1, "Error reading input")
    end

  be part2(notify: SolutionNotify tag) =>
    try
      let map = build_map("2024/06/input.txt")?
      var loopy_obstacles: USize = 0
      match find_guard(map)
      | let guard: Guard =>
        let start_pos = guard.pos
        // try setting an obstacle in brute force on every free space
        for (y, row) in map.pairs() do
          for (x, field) in row.pairs() do
            if field == MapFields.free() then
              // set the obstacle
              //debug("Putting an obstacle @ " + Pos(x, y).string())
              let cloned_map: Array[Array[U8] val] val =
              recover val
                let cloned = recover iso map.clone() end
                cloned(y)? =
                  recover val
                    let cloned_row = cloned(y)?.clone()
                    cloned_row(x)? = MapFields.obstacle()
                    consume cloned_row
                  end
                consume cloned
              end
              // walk the map until we visit a turning point again
              guard.reset_to(start_pos)
              let turning_points = Set[TurningPoint].create()
              while true do
                let next_pos = guard.next_pos()
                try
                  let next_field = cloned_map(next_pos.y)?(next_pos.x)?
                  if next_field == MapFields.obstacle() then
                    let previous_size = turning_points.size()
                    turning_points.set(TurningPoint(guard.pos, guard.dir))
                    if previous_size == turning_points.size() then
                      // we have a loop - already visited this turning point
                      //debug("loop @ " + guard.pos.string())
                      //print_turning_points(turning_points)
                      //print_map(cloned_map)
                      loopy_obstacles = loopy_obstacles + 1
                      break
                    end
                    guard.turn()
                  else
                    guard.move()
                  end
                else
                  // guard left the map, no loop
                  //debug("guard left the map @ " + guard.pos.string())
                  break
                end
              end
            end
          end
        end
        notify.done(this, 2, loopy_obstacles.string())
      | None =>
        notify.fail(this, 2, "Guard not found")
      end
    else
      notify.fail(this, 2, "Error reading input")
    end

  fun find_guard(map: Array[Array[U8] val] val): (Guard | None) =>
    for (y, row) in map.pairs() do
      for (x, field) in row.pairs() do
        if field == MapFields.guard() then
          return Guard(Pos(x, y))
        end
      end
    end
    None

  fun build_map(input_file: String): Array[Array[U8] val] val ? =>
    recover val
      Iter[String iso^](AOCUtils.get_input_lines(input_file, _env)?)
        .map[Array[U8] val]({(s) => recover val (consume s).iso_array() end})
        .collect(Array[Array[U8] val].create(64))
    end

  fun print_map(map: Array[Array[U8] val] val) =>
    var first: Bool = true
    for (y, row) in map.pairs() do
      if first then
        first = false
        _env.out.write("  ")
        for i in Range[USize](0, row.size()) do
          _env.out.write(i.string())
        end
        _env.out.print("")
      end
      _env.out.write(y.string() + " ")
      for (x, field) in row.pairs() do
        _env.out.write(recover val String .> push(field) end)
      end
      _env.out.print("")
    end
    _env.out.print("")

  fun print_turning_points(tps: Set[TurningPoint] box) =>
    for p in tps.values() do
      _env.out.write(p.string() + ", ")
    end
    _env.out.print("")

  fun debug(s: Stringable) =>
    _env.out.print(s.string())

class ref Guard
  var dir: Direction
  var pos: Pos

  new ref create(pos': Pos) =>
    pos = pos'
    dir = Up

  fun box next_pos(): Pos =>
    """
    move according to direction and return the next position
    while also changing its own position
    """
    let diff = dir.move()
    Pos((pos.x.isize() + diff._1).usize(), (pos.y.isize() + diff._2).usize())

  fun ref move(): Pos =>
    pos = next_pos()

  fun ref turn() =>
    dir = dir.turn()

  fun ref reset_to(pos': Pos) =>
    pos = pos'
    dir = Up

class val Pos is (Equatable[Pos] & Hashable)
  let x: USize
  let y: USize

  new val create(x': USize, y': USize) =>
    x = x'
    y = y'

  fun eq(that: box->Pos): Bool =>
    this.x.eq(that.x) and this.y.eq(that.y)

  fun box hash(): USize val =>
    ((x.u128() << x.bitwidth().u128()) or y.u128()).hash()

  fun box string(): String iso^ =>
    recover iso
      String.create(7) .> append(x.string()) .> append(",") .> append(y.string())
    end

class val TurningPoint is (Equatable[TurningPoint] & Hashable)
  let pos: Pos
  let dir: Direction

  new val create(pos': Pos, dir': Direction) =>
    pos = pos'
    dir = dir'

  fun eq(that: box->TurningPoint): Bool =>
    this.pos.eq(that.pos) and this.dir.eq(that.dir)
  
  fun box hash(): USize val =>
    this.pos.hash() xor dir.hash()

  fun box string(): String iso^ =>
    recover iso
      String.create(7) .> append(pos.string()) .> append(" ") .> append(match
      dir
      | Up => "^"
      | Left => "<"
      | Right => ">"
      | Down => "v"
      end)
    end

