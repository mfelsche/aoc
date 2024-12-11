use ".."
use "collections"
use "debug"
use "files"
use "itertools"
use "peg"

actor Solution is AocSolution
  let _env: Env

new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 7


  be part1(notify: SolutionNotify tag) =>
    let parser = FormulaParser()
    var result: U64 = 0
    try
      for line in AOCUtils.get_input_lines("2024/07/input.txt", _env)? do
        let source = Source.from_string(consume line)
        match recover val parser.parse(source) end
        | (let offset: USize, let ast: AST) =>
          //_env.out.print(recover val Printer(ast) end)
          var test_value: U64 = 0
          let operands: Array[U64] trn = operands.create()
          for child in ast.children.values() do
            match child
            | let inner: AST if inner.label() is Operands =>
              for num in inner.children.values() do
                let t = num as Token
                try
                  operands.push(t.string().u64()?)
                end
              end
            | let token: Token if token.label() is Num =>
              test_value = token.string().u64()?
            end
          end
          if solve(test_value, consume operands, false) then
            //_env.out.print(recover val Printer(ast) end)
            result = result + test_value
          end
        | (let offset: USize, let r: Parser val) =>
          let e = recover val SyntaxError(source, offset, r) end
          _env.err.writev(PegFormatError.console(e))
        end
      end
      notify.done(this, 1, result.string())
    else
      notify.fail(this, 1, "Error reading input")
    end


  be part2(notify: SolutionNotify tag) =>
    let parser = FormulaParser()
    var result: U64 = 0
    try
      for line in AOCUtils.get_input_lines("2024/07/input.txt", _env)? do
        let source = Source.from_string(consume line)
        match recover val parser.parse(source) end
        | (let offset: USize, let ast: AST) =>
          //_env.out.print(recover val Printer(ast) end)
          var test_value: U64 = 0
          let operands: Array[U64] trn = operands.create()
          for child in ast.children.values() do
            match child
            | let inner: AST if inner.label() is Operands =>
              for num in inner.children.values() do
                let t = num as Token
                try
                  operands.push(t.string().u64()?)
                end
              end
            | let token: Token if token.label() is Num =>
              test_value = token.string().u64()?
            end
          end
          if solve(test_value, consume operands, true) then
            //_env.out.print(recover val Printer(ast) end)
            //_env.out.print("+ " + test_value.string())
            result = result + test_value
          end
        | (let offset: USize, let r: Parser val) =>
          let e = recover val SyntaxError(source, offset, r) end
          _env.err.writev(PegFormatError.console(e))
        end
      end
      notify.done(this, 2, result.string())
    else
      notify.fail(this, 2, "Error reading input")
    end


  fun ref solve(test_value: U64, operands: Array[U64] val, concat: Bool = false): Bool  =>
    try
      let iter = operands.values()
      let tree =
        if iter.has_next() then
          let op = iter.next()?
          OpTree.create(op)
        else
          return false
        end
      while iter.has_next() do
        let operand = iter.next()?
        if not tree.populate(operand, test_value, concat) then
          return false
        end
      end
      tree.check(test_value, concat)
    else
      false
    end


class ref OpTree
  let value: U64

  var plus: (OpTree | None)
  var multiply: (OpTree | None)
  var concat: (OpTree | None)

  new ref create(value': U64) =>
    value = value'
    plus = None
    multiply = None
    concat = None

  fun ref populate(operand: U64, test_value: U64, have_concat: Bool): Bool =>
    match plus
    | None =>
      let new_value = value + operand
      plus = OpTree(new_value)
    | let plus_tree: OpTree =>
      plus_tree.populate(operand, test_value, have_concat)
    end
    match multiply
    | None =>
      let new_value = value * operand
      multiply = OpTree(new_value)
    | let m_tree: OpTree =>
      m_tree.populate(operand, test_value, have_concat)
    end
    if have_concat then
      match concat
      | None =>
        try
          let v = (value.string() + operand.string()).u64()?
          concat = OpTree(v)
        end
      | let c_tree: OpTree =>
        c_tree.populate(operand, test_value, have_concat)
      end
    end
    true
    
  fun ref check(test_value: U64, have_concat: Bool): Bool =>
    match plus
    | None =>
        if value == test_value then
          return true
        end
    | let plus_tree: OpTree =>
      if plus_tree.check(test_value, have_concat) then
        return true
      end
    end
    match multiply
    | None =>
      if value == test_value then
        return true
      end
    | let m_tree: OpTree =>
      if m_tree.check(test_value, have_concat) then
        return true
      end
    end
    if have_concat then
      match concat
      | None =>
        if value == test_value then
          return true
        end
      | let c_tree: OpTree =>
        if c_tree.check(test_value, have_concat) then
          return true
        end
      end
    end
    false

primitive FormulaParser
  fun apply(): Parser val =>
    recover val
      let digit19 = R('1', '9')
      let digit = R('0', '9')
      let digits = digit.many1()
      let number = ((digit19 * digits) / digit).term(Num)
      let formula = number * L(":") * number.many1().node(Operands)
      let whitespace = (L(" ") / L("\t") / L("\r") / L("\n")).many1()
      formula.hide(whitespace)
    end

primitive Num is Label fun text(): String => "num"
primitive Operands is Label fun text(): String => "operands"
