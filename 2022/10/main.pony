use ".."
use "debug"
use "itertools"
use "collections"

interface val Op
  fun cycles(): USize
  fun execute(register: Register ref)

primitive Noop
  fun cycles(): USize => 1
  fun execute(register: Register ref) => None

class val Addx
  let operand: I64

  new val create(operand': I64) =>
    operand = operand'

  fun cycles(): USize => 2
  fun execute(register: Register ref) =>
    register.add(operand)

class ref Register
  var x: I64

  new ref create() =>
    x = 1

  fun ref add(other: I64): None =>
    x = x + other

  fun read(): I64 =>
    x

class ref CRT
  embed screen: Array[Array[U8] ref] ref
  var pos: USize = 0

  new ref create() =>
    screen = Array[Array[U8] ref].create(6)
    for i in Range(0, 6) do
      screen.push(Array[U8].init('.', 40))
    end

  fun ref draw_pixel(sprite_pos: I64) ? =>
    let line = pos / 40
    let h_pos = pos % 40
    let pixel: U8 =
      if (h_pos.i64() == (sprite_pos - 1))
        or (h_pos.i64() == sprite_pos)
        or (h_pos.i64() == (sprite_pos + 1))
      then
        '#'
      else
        '.'
      end
    // draw on the screen
    screen(line)?(h_pos)? = pixel
    pos = pos + 1

  fun display(out: OutStream) =>
    for line in screen.values() do
      for c in line.values() do
        out.write(recover val String.from_utf32(c.u32()) end)
      end
      out.print("")
    end



actor Main
  new create(env: Env) =>
    try
      let ops: Iterator[Op] =
        Iter[String iso^](AOCUtils.get_input_lines("input.txt", env)?)
          .map[String val]({(s) => recover val consume s end})
          .filter({(s) => s.size() > 0 })
          .map_stateful[Op](
            {(s: String val): Op ? =>
              match s.substring(0, 4)
              | "noop" => Noop
              | "addx" =>
                let v = s.substring(5).i64()?
                Addx(v)
              else
                error
              end
            })
      let observe_cycles: Array[USize] = [20; 60; 100; 140; 180; 220]
      var observe_idx: USize = 0
      var sum: I64 = 0

      let crt = CRT

      // the register
      var register = Register
      // the cycle counter
      var cycle: USize = 0

      if ops.has_next() then
        var cur_op: Op = ops.next()?
        var op_latency: USize = cur_op.cycles()
        while ops.has_next() do
          cycle = cycle + 1
          let x = register.read()
          crt.draw_pixel(x)?
          //env.out.print("Cycle " + cycle.string() + ", X = " + register.read().string())
          try
            if cycle == observe_cycles(observe_idx)? then
              sum = sum + (cycle.i64() * x)
              observe_idx = observe_idx + 1
            end
          end

          op_latency = op_latency - 1

          if op_latency == 0 then
            cur_op.execute(register)
            cur_op = ops.next()?
            op_latency = cur_op.cycles()
          end
        end
        env.out.print("Sum: " + sum.string())
        crt.display(env.out)
      else
        env.exitcode(1)
      end
    else
      env.exitcode(1)
    end
