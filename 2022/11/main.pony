"""
--- Day 11: Monkey in the Middle ---

As you finally start making your way upriver, you realize your pack is much lighter than you remember. Just then, one of the items from your pack goes flying overhead. Monkeys are playing Keep Away with your missing things!

To get your stuff back, you need to be able to predict where the monkeys will throw your items. After some careful observation, you realize the monkeys operate based on how worried you are about each item.

You take some notes (your puzzle input) on the items each monkey currently has, how worried you are about those items, and how the monkey makes decisions based on your worry level. For example:

Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1

Each monkey has several attributes:

    Starting items lists your worry level for each item the monkey is currently holding in the order they will be inspected.
    Operation shows how your worry level changes as that monkey inspects an item. (An operation like new = old * 5 means that your worry level after the monkey inspected the item is five times whatever your worry level was before inspection.)
    Test shows how the monkey uses your worry level to decide where to throw an item next.
        If true shows what happens with an item if the Test was true.
        If false shows what happens with an item if the Test was false.

After each monkey inspects an item but before it tests your worry level, your relief that the monkey's inspection didn't damage the item causes your worry level to be divided by three and rounded down to the nearest integer.

The monkeys take turns inspecting and throwing items. On a single monkey's turn, it inspects and throws all of the items it is holding one at a time and in the order listed. Monkey 0 goes first, then monkey 1, and so on until each monkey has had one turn. The process of each monkey taking a single turn is called a round.

When a monkey throws an item to another monkey, the item goes on the end of the recipient monkey's list. A monkey that starts a round with no items could end up inspecting and throwing many items by the time its turn comes around. If a monkey is holding no items at the start of its turn, its turn ends.

In the above example, the first round proceeds as follows:

Monkey 0:
  Monkey inspects an item with a worry level of 79.
    Worry level is multiplied by 19 to 1501.
    Monkey gets bored with item. Worry level is divided by 3 to 500.
    Current worry level is not divisible by 23.
    Item with worry level 500 is thrown to monkey 3.
  Monkey inspects an item with a worry level of 98.
    Worry level is multiplied by 19 to 1862.
    Monkey gets bored with item. Worry level is divided by 3 to 620.
    Current worry level is not divisible by 23.
    Item with worry level 620 is thrown to monkey 3.
Monkey 1:
  Monkey inspects an item with a worry level of 54.
    Worry level increases by 6 to 60.
    Monkey gets bored with item. Worry level is divided by 3 to 20.
    Current worry level is not divisible by 19.
    Item with worry level 20 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 65.
    Worry level increases by 6 to 71.
    Monkey gets bored with item. Worry level is divided by 3 to 23.
    Current worry level is not divisible by 19.
    Item with worry level 23 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 75.
    Worry level increases by 6 to 81.
    Monkey gets bored with item. Worry level is divided by 3 to 27.
    Current worry level is not divisible by 19.
    Item with worry level 27 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 74.
    Worry level increases by 6 to 80.
    Monkey gets bored with item. Worry level is divided by 3 to 26.
    Current worry level is not divisible by 19.
    Item with worry level 26 is thrown to monkey 0.
Monkey 2:
  Monkey inspects an item with a worry level of 79.
    Worry level is multiplied by itself to 6241.
    Monkey gets bored with item. Worry level is divided by 3 to 2080.
    Current worry level is divisible by 13.
    Item with worry level 2080 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 60.
    Worry level is multiplied by itself to 3600.
    Monkey gets bored with item. Worry level is divided by 3 to 1200.
    Current worry level is not divisible by 13.
    Item with worry level 1200 is thrown to monkey 3.
  Monkey inspects an item with a worry level of 97.
    Worry level is multiplied by itself to 9409.
    Monkey gets bored with item. Worry level is divided by 3 to 3136.
    Current worry level is not divisible by 13.
    Item with worry level 3136 is thrown to monkey 3.
Monkey 3:
  Monkey inspects an item with a worry level of 74.
    Worry level increases by 3 to 77.
    Monkey gets bored with item. Worry level is divided by 3 to 25.
    Current worry level is not divisible by 17.
    Item with worry level 25 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 500.
    Worry level increases by 3 to 503.
    Monkey gets bored with item. Worry level is divided by 3 to 167.
    Current worry level is not divisible by 17.
    Item with worry level 167 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 620.
    Worry level increases by 3 to 623.
    Monkey gets bored with item. Worry level is divided by 3 to 207.
    Current worry level is not divisible by 17.
    Item with worry level 207 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 1200.
    Worry level increases by 3 to 1203.
    Monkey gets bored with item. Worry level is divided by 3 to 401.
    Current worry level is not divisible by 17.
    Item with worry level 401 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 3136.
    Worry level increases by 3 to 3139.
    Monkey gets bored with item. Worry level is divided by 3 to 1046.
    Current worry level is not divisible by 17.
    Item with worry level 1046 is thrown to monkey 1.

After round 1, the monkeys are holding items with these worry levels:

Monkey 0: 20, 23, 27, 26
Monkey 1: 2080, 25, 167, 207, 401, 1046
Monkey 2:
Monkey 3:

Monkeys 2 and 3 aren't holding any items at the end of the round; they both inspected items during the round and threw them all before the round ended.

This process continues for a few more rounds:

After round 2, the monkeys are holding items with these worry levels:
Monkey 0: 695, 10, 71, 135, 350
Monkey 1: 43, 49, 58, 55, 362
Monkey 2:
Monkey 3:

After round 3, the monkeys are holding items with these worry levels:
Monkey 0: 16, 18, 21, 20, 122
Monkey 1: 1468, 22, 150, 286, 739
Monkey 2:
Monkey 3:

After round 4, the monkeys are holding items with these worry levels:
Monkey 0: 491, 9, 52, 97, 248, 34
Monkey 1: 39, 45, 43, 258
Monkey 2:
Monkey 3:

After round 5, the monkeys are holding items with these worry levels:
Monkey 0: 15, 17, 16, 88, 1037
Monkey 1: 20, 110, 205, 524, 72
Monkey 2:
Monkey 3:

After round 6, the monkeys are holding items with these worry levels:
Monkey 0: 8, 70, 176, 26, 34
Monkey 1: 481, 32, 36, 186, 2190
Monkey 2:
Monkey 3:

After round 7, the monkeys are holding items with these worry levels:
Monkey 0: 162, 12, 14, 64, 732, 17
Monkey 1: 148, 372, 55, 72
Monkey 2:
Monkey 3:

After round 8, the monkeys are holding items with these worry levels:
Monkey 0: 51, 126, 20, 26, 136
Monkey 1: 343, 26, 30, 1546, 36
Monkey 2:
Monkey 3:

After round 9, the monkeys are holding items with these worry levels:
Monkey 0: 116, 10, 12, 517, 14
Monkey 1: 108, 267, 43, 55, 288
Monkey 2:
Monkey 3:

After round 10, the monkeys are holding items with these worry levels:
Monkey 0: 91, 16, 20, 98
Monkey 1: 481, 245, 22, 26, 1092, 30
Monkey 2:
Monkey 3:

...

After round 15, the monkeys are holding items with these worry levels:
Monkey 0: 83, 44, 8, 184, 9, 20, 26, 102
Monkey 1: 110, 36
Monkey 2:
Monkey 3:

...

After round 20, the monkeys are holding items with these worry levels:
Monkey 0: 10, 12, 14, 26, 34
Monkey 1: 245, 93, 53, 199, 115
Monkey 2:
Monkey 3:

Chasing all of the monkeys at once is impossible; you're going to have to focus on the two most active monkeys if you want any hope of getting your stuff back. Count the total number of times each monkey inspects items over 20 rounds:

Monkey 0 inspected items 101 times.
Monkey 1 inspected items 95 times.
Monkey 2 inspected items 7 times.
Monkey 3 inspected items 105 times.

In this example, the two most active monkeys inspected items 101 and 105 times. The level of monkey business in this situation can be found by multiplying these together: 10605.

Figure out which monkeys to chase by counting how many items they inspect over 20 rounds. What is the level of monkey business after 20 rounds of stuff-slinging simian shenanigans?

--- Part Two ---

You're worried you might not ever get your items back. So worried, in fact, that your relief that a monkey's inspection didn't damage an item no longer causes your worry level to be divided by three.

Unfortunately, that relief was all that was keeping your worry levels from reaching ridiculous levels. You'll need to find another way to keep your worry levels manageable.

At this rate, you might be putting up with these monkeys for a very long time - possibly 10000 rounds!

With these new rules, you can still figure out the monkey business after 10000 rounds. Using the same example above:

== After round 1 ==
Monkey 0 inspected items 2 times.
Monkey 1 inspected items 4 times.
Monkey 2 inspected items 3 times.
Monkey 3 inspected items 6 times.

== After round 20 ==
Monkey 0 inspected items 99 times.
Monkey 1 inspected items 97 times.
Monkey 2 inspected items 8 times.
Monkey 3 inspected items 103 times.

== After round 1000 ==
Monkey 0 inspected items 5204 times.
Monkey 1 inspected items 4792 times.
Monkey 2 inspected items 199 times.
Monkey 3 inspected items 5192 times.

== After round 2000 ==
Monkey 0 inspected items 10419 times.
Monkey 1 inspected items 9577 times.
Monkey 2 inspected items 392 times.
Monkey 3 inspected items 10391 times.

== After round 3000 ==
Monkey 0 inspected items 15638 times.
Monkey 1 inspected items 14358 times.
Monkey 2 inspected items 587 times.
Monkey 3 inspected items 15593 times.

== After round 4000 ==
Monkey 0 inspected items 20858 times.
Monkey 1 inspected items 19138 times.
Monkey 2 inspected items 780 times.
Monkey 3 inspected items 20797 times.

== After round 5000 ==
Monkey 0 inspected items 26075 times.
Monkey 1 inspected items 23921 times.
Monkey 2 inspected items 974 times.
Monkey 3 inspected items 26000 times.

== After round 6000 ==
Monkey 0 inspected items 31294 times.
Monkey 1 inspected items 28702 times.
Monkey 2 inspected items 1165 times.
Monkey 3 inspected items 31204 times.

== After round 7000 ==
Monkey 0 inspected items 36508 times.
Monkey 1 inspected items 33488 times.
Monkey 2 inspected items 1360 times.
Monkey 3 inspected items 36400 times.

== After round 8000 ==
Monkey 0 inspected items 41728 times.
Monkey 1 inspected items 38268 times.
Monkey 2 inspected items 1553 times.
Monkey 3 inspected items 41606 times.

== After round 9000 ==
Monkey 0 inspected items 46945 times.
Monkey 1 inspected items 43051 times.
Monkey 2 inspected items 1746 times.
Monkey 3 inspected items 46807 times.

== After round 10000 ==
Monkey 0 inspected items 52166 times.
Monkey 1 inspected items 47830 times.
Monkey 2 inspected items 1938 times.
Monkey 3 inspected items 52013 times.

After 10000 rounds, the two most active monkeys inspected items 52166 and 52013 times. Multiplying these together, the level of monkey business in this situation is now 2713310158.

Worry levels are no longer divided by three after each item is inspected; you'll need to find another way to keep your worry levels manageable. Starting again from the initial state in your puzzle input, what is the level of monkey business after 10000 rounds?
"""

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
