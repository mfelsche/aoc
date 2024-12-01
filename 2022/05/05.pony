use ".."
use "debug"
use "collections"

primitive InitialStack
primitive Movements
type ParserState is (InitialStack | Movements)

// TODO: make it an interface
type Stack is Array[U8] ref
type Stacks is Array[Stack] ref

class Movement
  let _line: String val
  let amount: USize
  let src: USize
  let target: USize

  new parse(line: String val) ? =>
    _line = line
    let splitted = line.split_by(" ")
    amount = splitted(1)?.usize()?
    src = splitted(3)?.usize()?
    target = splitted(5)?.usize()?

  fun string(): String iso^ =>
    recover iso String.create().>append(_line) end

class CrateMover9000
  let _stacks: Stacks

  new create(stacks': Stacks) =>
    _stacks = stacks'

  fun ref execute(movement: Movement) ? =>
    let src = _stacks(movement.src - 1)?
    let dest = _stacks(movement.target - 1)?
    for i in Range[USize](0, movement.amount) do
      dest.push(src.pop()?)
    end

class CrateMover9001
  let _stacks: Stacks

  new create(stacks': Stacks) =>
    _stacks = stacks'

  fun ref execute(movement: Movement) ? =>
    let src = _stacks(movement.src - 1)?
    let dest = _stacks(movement.target - 1)?
    let src_idx = src.size() - movement.amount
    let dest_idx = dest.size()
    src.copy_to(dest, src_idx, dest_idx, movement.amount)
    src.truncate(src_idx)


actor Main
  fun box debug_stacks(out: OutStream, stacks: Stacks) =>
    ifdef debug then
      var num = USize(1)
      for stack in stacks.values() do
        out.write(num.string() + " ")
        for elem in stack.values() do
          out.write("[" + String.from_utf32(elem.u32()) + "]")
          out.write(" ")
        end
        out.print("")

        num = num + 1
      end
    end


  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var state: ParserState = InitialStack
      let stacks: Stacks = Stacks.create(0)
      var stacks9001: Stacks = Stacks.create(0)
      let crane9000 = CrateMover9000.create(stacks)
      let crane9001 = CrateMover9001.create(stacks9001)
      for line in lines do
        match state
        | InitialStack =>
          // parse the initial stack
          if line.size() == 0 then
            // finish parsing the initial stack
            for stack in stacks.values() do
              // as we inserted the values in the wrong order
              // we gotta reverse here
              stack.reverse_in_place()

              // prepare 9001 stacks
              stacks9001.push(stack.clone())

            end
            env.out.print("Initial:")
            debug_stacks(env.out, stacks)
            state = Movements
          else
            var i = ISize(0)
            var slot_id = USize(0)
            while i.usize() < line.size() do
              let stack_slot: String ref = line.substring(
                i = i+3, // add, assign and return old value
                i = i+1  // add, assign and return old valie
              )
              stack_slot.strip()
              // check if we have an empty slot or a stack index number or a
              // proper filled stack slot
              if (stack_slot.size() > 0) and (stack_slot(0)? == U8('[')) then
                // we have a stack slot
                // ensure we have the stacks inserted that we need
                while stacks.size() < (slot_id + 1) do
                  stacks.push(Stack.create(0))
                end
                // we insert the top elements at the bottom now and later need to reverse the array
                let slot_value: U8 = stack_slot(1)?
                stacks(slot_id)?.push(slot_value)
              end


              slot_id = slot_id + 1
            end

          end

        | Movements =>
          if line.size() == 0 then continue end
          let movement = Movement.parse(consume line)?
          try
            crane9000.execute(movement)?
            crane9001.execute(movement)?
          else
            env.err.print("Error executing movement " + movement.string())
          end

        end
      end
      env.out.print("Result with CrateMover9000:")
      print_result(stacks, env.out)?

      env.out.print("Result with CrateMover9001:")
      print_result(stacks9001, env.out)?

    else
      env.exitcode(1)
    end

  fun print_result(stacks: Stacks, out: OutStream)? =>
    debug_stacks(out, stacks)
    let res = recover iso Array[U8].create(stacks.size()) end
    for stack in stacks.values() do
      res.push(stack.pop()?)
    end
    out.print(String.from_iso_array(consume res))

