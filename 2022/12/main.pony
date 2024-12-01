use ".."
use "collections"
use "debug"
use "format"
use "itertools"
use @sleep[None](d: I32)

type Matrix is Array[Array[U8] val] val
type MatrixBuilder is Array[Array[U8] val] trn

class val Pos
  let _p: U32

  new val create(y': USize, x': USize) =>
    _p = (y'.u32() << 16) or (x'.u32() and 0xFFFF)

  fun x(): USize =>
    (_p and 0xFFFF).usize()

  fun y(): USize =>
    (_p >> 16).usize()

  fun steps(): Iterator[(Dir, Pos)] =>
    [
      (Dirs.up(), up())
      (Dirs.down(), down())
      (Dirs.left(), left())
      (Dirs.right(), right())
    ].values()

  fun up(): Pos =>
    Pos(y() + 1, x())

  fun down(): Pos =>
    Pos(y() - 1, x())

  fun left(): Pos =>
    Pos(y(), x() - 1)

  fun right(): Pos =>
    Pos(y(), x() + 1)

  fun eq(other: Pos): Bool =>
    _p == other._p

  fun ne(other: Pos): Bool =>
    not eq(other)

  fun hash(): USize =>
    _p.hash()

  fun string(): String iso^ =>
    recover iso
      String
        .> append(y().string())
        .> append(",")
        .> append(x().string())
    end


primitive MapUtil
  fun find_point(needle: U8, haystack: Matrix): Pos ? =>
    for (y, line) in Iter[Array[U8] val](haystack.values()).enum() do
      for (x, height) in Iter[U8](line.values()).enum() do
        if height == needle then
          return Pos(y, x)
        end
      end
    end
    error

type Dir is U8

primitive Dirs
  fun up(): Dir     => 1
  fun left(): Dir   => 2
  fun right(): Dir  => 4
  fun down(): Dir   => 8

class Step
  var dir: Dir
  var _possible_dirs: Dir

  new create(from: Pos, to: Pos, exclude_dirs: Dir) ? =>
    dir =
      match from.x() - to.x()
      | 0 =>
        match from.y() - to.y()
        | 0 => error
        | 1 => Dirs.up()
        | -1 => Dirs.down()
        else
          error
        end
      | 1 => Dirs.left()
      | -1 => Dirs.right()
      else
        error
      end
    _possible_dirs = ((not dir) and (not exclude_dirs))

  fun ref backtrack(dir': Dir) =>
    dir = dir'
    _possible_dirs = (_possible_dirs and (not dir))

  fun possible_dirs(cur: Pos): Iterator[(Dir, Pos)] =>
    let arr = Array[(Dir, Pos)].create(0)
    if (_possible_dirs and Dirs.up()) != 0 then
      arr.push((Dirs.up(), cur.up()))
    elseif (_possible_dirs and Dirs.right()) != 0 then
      arr.push((Dirs.right(), cur.right()))
    elseif (_possible_dirs and Dirs.down()) != 0 then
      arr.push((Dirs.down(), cur.down()))
    elseif (_possible_dirs and Dirs.left()) != 0 then
      arr.push((Dirs.left(), cur.left()))
    end
    arr.values()

  fun exhausted(): Bool =>
    _possible_dirs == 0

  fun string(): String iso^ =>
    recover iso
      String
        .> append("dir: ")
        .> append(dir.string())
        .> append(" (")
        .> append(Format.int[U8](_possible_dirs where fmt = FormatBinary))
        .> append(")")
    end



class PathFinder
  let _steps: Array[Step] ref = _steps.create(64)
  let _map: Matrix
  let _goal: Pos
  let _start: Pos

  var _cur: Pos
  var _cur_height: U8
  var _steps_taken: USize = 0
  var _min_steps: USize = USize.max_value()
  var _trace: Map[Pos, USize] = _trace.create()

  new ref create(map: Matrix, start: Pos, goal: Pos) ? =>
    _map = map
    _start = start
    _cur = _start
    _cur_height = _map(_cur.y())?(_cur.x())?
    _goal = goal

  fun exhausted(): Bool =>
    try
      _steps(0)?.exhausted()
    else
      // still at the start
      false
    end

  fun ref do_step(to: Pos) ? =>
    _trace.insert(_cur, _steps_taken)
    _steps_taken = _steps_taken + 1
    _cur = to
    _cur_height = _map(_cur.y())?(_cur.x())?

  fun ref undo_step() ? =>
    _steps_taken = _steps_taken - 1
    _cur = _trace.pop()?
    _cur_height = _map(_cur.y())?(_cur.x())?


  fun fix_h(h: U8): U8 =>
    match h
    | 'S' => 'a'
    | 'E' => 'z'
    | let x: U8 => x
    end

  fun is_visitable(pos: Pos): Bool =>
    try
      let pos_height = fix_h(_map(pos.y())?(pos.x())?)
      pos_height <= (fix_h(_cur_height) + 1)
    else
      // out of bounds
      false
    end

  fun ref find() ? =>
    while not exhausted() do
      // reached the end
      if _cur_height == 'E' then
        Debug("!!! GOAL !!!")
        Debug(_steps_taken.string())
        Debug("!!! GOAL !!!")
        // check if we have found the minimum path
        _min_steps = _min_steps.min(_steps_taken)
        // backtrack until exhausted
        backtrack()?
        continue
      elseif _min_steps < _steps_taken then
        // avoid paths we have already taken that are longer than the known
        // minimum
        backtrack()?
        continue
      end



      var exclude_dirs: Dir = 0
      let needs_continue =
        // look into every possible direction
        for (dir, new_pos) in _cur.steps() do
          Debug("checking " + new_pos.string())
          // every path that comes along a pos we've already been faster can be discarded
          if _trace(new_pos)? <= _steps_taken  then
            Debug("already visited: " + new_pos.string())
            exclude_dirs = exclude_dirs or dir
            continue
          end
          try
            if is_visitable(new_pos) then
              Debug("step: " + new_pos.string())
              let step = Step(_cur, new_pos, exclude_dirs)?
              Debug(step)
              _steps.push(step)
              do_step(new_pos)?
              break true
            end
          else
            // out of bounds
            exclude_dirs = exclude_dirs or dir
          end
          false
        else
          false
        end
      if needs_continue then
        continue
      else
        // we have no way left, so backtrack
        backtrack()?
      end
    end

  fun ref backtrack() ? =>
    // adapt the last step so it is one from its possible ones, otherwise we
    // are exhausted and need to backtrack further
    // undo the last step
    Debug("backtrack")
    undo_step()?
    var last = _steps.pop()?
    while not last.exhausted() do
      // check all possible directions we didnt take yet
      Debug(_cur)
      for (dir, new_pos) in last.possible_dirs(_cur) do
        Debug("checking " + new_pos.string() + " (bt)")
        if is_visitable(new_pos) then
          // do the backtracked step and try to continue from there
          Debug("Backtracking to " + new_pos.string())
          last.backtrack(dir)
          Debug(last)
          _steps.push(last)
          do_step(new_pos)?
          return
        end
      end
      // exhausted, exhaust further
      undo_step()?
      last = _steps.pop()?
    end

actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input2.txt", env)?
      let builder = recover trn MatrixBuilder.create(0) end
      for line in lines do
        if line.size() == 0 then continue end
        builder.push(recover val (consume line).iso_array() end)
      end
      let matrix: Matrix = consume builder
      let dims = (matrix.size(), matrix(0)?.size())

      // find start point
      let start = MapUtil.find_point('S', matrix)?
      let goal  = MapUtil.find_point('E', matrix)?
      Debug("start: " + start.string())
      Debug("goal: " + goal.string())

      let finder = PathFinder(matrix, start, goal)?
      let min_steps = finder.find()?
      env.out.print(min_steps.string())
    else
      env.exitcode(1)
    end

