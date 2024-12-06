use ".."
use "collections"
use "debug"

actor Solution is AocSolution
  let _env: Env
  var _result: USize = 0
  var _searchers: SetIs[XmasSearcher tag] = _searchers.create()
  var _all_searchers_started: Bool = false
  var _notify: (SolutionNotify tag | None) = None
  var _running_part: U32 = 1

  new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 4

  fun get_input_matrix(): Array[Array[U8] val] val ? =>
    let matrix_builder: Array[Array[U8] val] trn = matrix_builder.create()
    for line in AOCUtils.get_input_lines("2024/04/input.txt", _env)? do
      let row: Array[U8] val = recover val (consume line).iso_array() end
      matrix_builder.push(row)
    end
    consume matrix_builder

  be part1(notify: SolutionNotify tag) =>
    _result = 0
    _notify = notify
    _running_part = 1
    try
      let matrix = this.get_input_matrix()?
      for (y, row) in matrix.pairs() do
        for (x, letter) in row.pairs() do
          if letter == 'X' then
            let searcher = XmasSearcher.create(matrix, this)
            _searchers.set(searcher)
            searcher.search_xmas((x, y), this)
          end
        end
      end
      _all_searchers_started = true // no more
      if _searchers.size() == 0 then
        // no searchers started
        notify.done(recover tag this end, 1, _result.string())
      end

    else
      notify.fail(this, 1, "Error reading input")
    end

  be found_xmas() =>
    _result = _result + 1

  be done(searcher: XmasSearcher tag) =>
    _searchers.unset(searcher)
    if (_searchers.size() == 0) and _all_searchers_started then
      try
        (_notify as SolutionNotify).done(recover tag this end, _running_part, _result.string())
      end
    end

  be part2(notify: SolutionNotify tag) =>
    _result = 0
    _notify = notify
    _running_part = 2
    try
      let matrix = this.get_input_matrix()?
      for (y, row) in matrix.pairs() do
        for (x, letter) in row.pairs() do
          if letter == 'A' then
            let searcher = XmasSearcher.create(matrix, this)
            _searchers.set(searcher)
            searcher.search_x_mas((x, y), this)
          end
        end
      end
      _all_searchers_started = true
      if _searchers.size() == 0 then
        // no searchers started
        notify.done(recover tag this end, 2, _result.string())
      end

    else
      notify.fail(this, 2, "Error reading input")
    end
    

interface tag SearchNotify
  be found_xmas()
  be done(searcher: XmasSearcher)

actor XmasSearcher
  let _matrix: Array[Array[U8] val] val
  let _notify: SearchNotify tag
  let directions: Array[(ISize, ISize)] val = [
    (0, 1)
    (1, 1)
    (1, 0)
    (1, -1)
    (0, -1)
    (-1, -1)
    (-1, 0)
    (-1, 1)
  ]

  new create(
    matrix: Array[Array[U8] val] val,
    notify: SearchNotify tag
  ) =>
    _matrix = matrix
    _notify = notify
  
  be search_xmas(
    start: (USize, USize),
    notify: SearchNotify tag) =>
    for direction in directions.values() do
      let m_pos = ((start._1.isize() + (1 * direction._1)).usize(), (start._2.isize() + (1 * direction._2)).usize())
      let a_pos = ((start._1.isize() + (2 * direction._1)).usize(), (start._2.isize() + (2 * direction._2)).usize())
      let s_pos = ((start._1.isize() + (3 * direction._1)).usize(), (start._2.isize() + (3 * direction._2)).usize())
      try
        if 
          (_matrix(m_pos._2)?(m_pos._1)? == 'M')
          and (_matrix(a_pos._2)?(a_pos._1)? == 'A')
          and (_matrix(s_pos._2)?(s_pos._1)? == 'S') then
            _notify.found_xmas()
          end
      end
    end
    _notify.done(this)

  be search_x_mas(start: (USize, USize), notify: SearchNotify tag) =>
    """
    start is the A in the middle, check that we have an x-mas in some direction.
    """
    let top_left = ((start._1.isize() -1).usize(), (start._2.isize() + 1).usize())
    let top_right = ((start._1.isize() + 1).usize(), (start._2.isize() + 1).usize())
    let bottom_left = ((start._1.isize() - 1).usize(), (start._2.isize() - 1).usize())
    let bottom_right = ((start._1.isize() + 1).usize(), (start._2.isize() - 1).usize())

    try
      let cross1: (U8, U8) = (
        _matrix(top_left._2)?(top_left._1)?,
        _matrix(bottom_right._2)?(bottom_right._1)?
      )
      let cross2: (U8, U8) = (
        _matrix(top_right._2)?(top_right._1)?,
        _matrix(bottom_left._2)?(bottom_left._1)?
      )
      match cross1
      | ('M', 'S') | ('S', 'M') =>
        match cross2
        | ('M', 'S') | ('S', 'M') =>
          notify.found_xmas()
        end
      end
    end

    notify.done(this)

