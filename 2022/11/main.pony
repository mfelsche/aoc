use ".."
use "files"
use "peg"
use "collections"
use "debug"

class val MonkeyAST
  """
  Wraps the monkey AST and provides functions to extract the most important data
  """
  let _ast: AST val
  new val create(ast: AST val) =>
    _ast = ast

  fun id(): USize ? =>
    let monkey_num = _ast.extract() as AST
    let num = monkey_num.extract() as Token
    num.string().usize()?

  fun starting_items(): Array[USize] val ? =>
    let items = _ast.children(1)? as AST
    let numbers = items.extract() as AST
    let s_items = recover trn Array[USize].create(numbers.size()) end
    for child in numbers.children.values() do
      let tok = child as Token
      s_items.push(tok.string().usize()?)
    end
    consume s_items

  fun operation(): {val(USize): USize} val ? =>
    let op = _ast.children(2)? as AST
    let rhs = op.children(3)? as Token
    let operator = op.children(2)? as Token
    match (operator.string(), rhs.string())
    | ("*", "old") => {(old) => old * old }
    | ("+", "old") => {(old) => old + old }
    | ("+", let num: String iso) =>
      let n = (consume num).usize()?
      {(old) => old + n}
    | ("*", let num: String iso) =>
      let n = (consume num).usize()?
      {(old) => old * n}
    else
      error
    end

  fun divisible_by(): USize ? =>
    let test = _ast.children(3)? as AST
    (test.extract() as Token).string().usize()?

  fun throw_to_monkey(condition: Bool): USize ? =>
    let test = _ast.children(3)? as AST
    for i in Range(1, test.size()) do
      let ifast = test.children(i)? as AST
      let cond = ifast.extract() as Token
      let cstr = recover val cond.string() end
      match (cstr, condition)
      | ("true", true) =>
        return (ifast.children(1)? as Token).string().usize()?
      | ("false", false) =>
        return (ifast.children(1)? as Token).string().usize()?
      else
        continue
      end
    end
    error


actor Monkey
  let _id: USize
  embed _items: Array[USize] ref
  let _op: {val(USize): USize} val
  let _divisible_by: USize
  let _throw_to: (USize, USize)
    """if (true, false)"""
  let _report_to: Main tag
  let _thingy: USize

  var _next: (Monkey | None) = None
  var _first: (Monkey | None) = None
  var _items_inspected: USize = 0

  new create(
    id: USize,
    items: Array[USize] val,
    operation: {val(USize): USize} val,
    divisible_by: USize,
    throw_to: (USize, USize),
    report_to: Main tag,
    thingy: USize
  ) =>
    _id = id
    _items = Array[USize].create(items.size())
    _items.append(items)

    _op = operation
    _divisible_by = divisible_by
    _throw_to = throw_to
    _report_to = report_to
    _thingy = thingy

  be set_next(m: Monkey) =>
    _next = m

  be set_first(m: Monkey) =>
    _first = m

  fun get_next(): Monkey ? =>
    try
      _next as Monkey
    else
      _first as Monkey
    end

  fun debug(m: String val) =>
    Debug(_id.string() + " " + m)

  be turn(round: USize) =>
    // USE 20 FOR PART 1
    if round == 10_000 then
      // report the number of inspected items
      _report_to.report(_id, _items_inspected)
      try
        (_next as Monkey).turn(round)
      end
    else
      while _items.size() > 0 do
        try
          let item: USize = _items.shift()?
          _items_inspected = _items_inspected + 1
          // inspect item
          var worry_level: USize = _op(item)
          // apply relief
          worry_level = worry_level % _thingy
          // COMMENT THE NEXT LINE IN FOR PART 1
          // worry_level = worry_level / 3
          // test
          let monkey: USize =
            if (worry_level % _divisible_by) == 0 then
              _throw_to._1
            else
              _throw_to._2
            end
          // throw the item
          try
            get_next()?.throw(monkey, worry_level)
          else
            Debug("nowhere to throw")
          end

        end
      end
      next_turn(round)
    end

  fun next_turn(round: USize) =>
    match _next
    | let m: Monkey => // it is the next monkeys turn
        m.turn(round)
    | None =>
      match _first
      | let f: Monkey => // begin the next round
        //Debug("starting round " + (round + 1).string())
        f.turn(round + 1)
      end
    end


  be throw(monkey: USize, item: USize) =>
    if _id == monkey then
      _items.push(item)
    else
      try
        (_next as Monkey).throw(monkey, item)
      else
        try
          (_first as Monkey).throw(monkey, item)
        end
      end
    end

actor Main

  let _max_inspected: MaxHeap[USize] = MaxHeap[USize].create(2)
  var _expected_reports: USize = 0
  let _out: OutStream

  be report(monkey_id: USize, num_inspections: USize) =>
    Debug("Monkey " + monkey_id.string() + " reported " + num_inspections.string())
    _expected_reports = _expected_reports - 1
    _max_inspected.push(num_inspections)
    try
      if _expected_reports == 0 then
        let m1 = _max_inspected.pop()?
        _out.write(m1.string())
        _out.write(" * ")
        let m2 = _max_inspected.pop()?
        _out.write(m2.string())
        _out.write(" = ")
        _out.print((m1 * m2).string())
      end
    end

  new create(env: Env) =>
    _out = env.out
    try
      let f_auth = FileAuth(env.root)
      let monkey_peg_path = FilePath(f_auth, "monkey.peg")
      let monkey_peg = Source(monkey_peg_path)?
      let parser =
        match recover val PegCompiler(monkey_peg) end
        | let p: Parser val => p
        | let errors: Array[PegError] val =>
          for e in errors.values() do
            _out.writev(PegFormatError.console(e))
          end
          error
        end
      let input = Source(FilePath(f_auth, "input.txt"))?
      let ast =
        match recover val parser.parse(input) end
        | (_, let r: ASTChild) =>
          let monkeys = Array[Monkey].create(8)

          let monkeys_ast = r as AST
          var thingy = USize(0)

          for monkey in monkeys_ast.children.values() do
            let m_ast = monkey as AST
            let mast = MonkeyAST(m_ast)
            if thingy == 0 then
              thingy = mast.divisible_by()?
            else
              thingy = thingy * mast.divisible_by()?
            end
          end
          // create monkey actors
          for monkey in monkeys_ast.children.values() do
            let m_ast = monkey as AST
            let mast = MonkeyAST(m_ast)
            let id = mast.id()?
            let starting_items = mast.starting_items()?
            let divisible_by = mast.divisible_by()?

            let m_a = Monkey(
              mast.id()?,
              starting_items,
              mast.operation()?,
              divisible_by,
              (mast.throw_to_monkey(true)?, mast.throw_to_monkey(false)?),
              this,
              thingy
            )
            monkeys.push(m_a)
          end

          // set the number of expected reports
          _expected_reports = monkeys.size()

          // let the monkeys know each other
          // so they are able to throw items at each other
          let m_iter = monkeys.values()
          if m_iter.has_next() then
            var last = m_iter.next()?
            var first = last
            for monkey in m_iter do
              last.set_next(monkey)
              last = monkey
            end
            last.set_first(first)

            // start the rounds

            first.turn(0)
          else
            // no monkeys
            error
          end
          //env.out.print(recover val Printer(r) end)
        | (let offset: USize, let r: Parser val) =>
          let e = recover val SyntaxError(input, offset, r) end
          _out.writev(PegFormatError.console(e))
        end
    else
      env.exitcode(1)
    end
