"""
--- Day 5: Supply Stacks ---

The expedition can depart as soon as the final supplies have been unloaded from the ships. Supplies are stored in stacks of marked crates, but because the needed supplies are buried under many other crates, the crates need to be rearranged.

The ship has a giant cargo crane capable of moving crates between stacks. To ensure none of the crates get crushed or fall over, the crane operator will rearrange them in a series of carefully-planned steps. After the crates are rearranged, the desired crates will be at the top of each stack.

The Elves don't want to interrupt the crane operator during this delicate procedure, but they forgot to ask her which crate will end up where, and they want to be ready to unload them as soon as possible so they can embark.

They do, however, have a drawing of the starting stacks of crates and the rearrangement procedure (your puzzle input). For example:

    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2

In this example, there are three stacks of crates. Stack 1 contains two crates: crate Z is on the bottom, and crate N is on top. Stack 2 contains three crates; from bottom to top, they are crates M, C, and D. Finally, stack 3 contains a single crate, P.

Then, the rearrangement procedure is given. In each step of the procedure, a quantity of crates is moved from one stack to a different stack. In the first step of the above rearrangement procedure, one crate is moved from stack 2 to stack 1, resulting in this configuration:

[D]
[N] [C]
[Z] [M] [P]
 1   2   3

In the second step, three crates are moved from stack 1 to stack 3. Crates are moved one at a time, so the first crate to be moved (D) ends up below the second and third crates:

        [Z]
        [N]
    [C] [D]
    [M] [P]
 1   2   3

Then, both crates are moved from stack 2 to stack 1. Again, because crates are moved one at a time, crate C ends up below crate M:

        [Z]
        [N]
[M]     [D]
[C]     [P]
 1   2   3

Finally, one crate is moved from stack 1 to stack 2:

        [Z]
        [N]
        [D]
[C] [M] [P]
 1   2   3

The Elves just need to know which crate will end up on top of each stack; in this example, the top crates are C in stack 1, M in stack 2, and Z in stack 3, so you should combine these together and give the Elves the message CMZ.

After the rearrangement procedure completes, what crate ends up on top of each stack?

--- Part Two ---

As you watch the crane operator expertly rearrange the crates, you notice the process isn't following your prediction.

Some mud was covering the writing on the side of the crane, and you quickly wipe it away. The crane isn't a CrateMover 9000 - it's a CrateMover 9001.

The CrateMover 9001 is notable for many new and exciting features: air conditioning, leather seats, an extra cup holder, and the ability to pick up and move multiple crates at once.

Again considering the example above, the crates begin in the same configuration:

    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

Moving a single crate from stack 2 to stack 1 behaves the same as before:

[D]
[N] [C]
[Z] [M] [P]
 1   2   3

However, the action of moving three crates from stack 1 to stack 3 means that those three moved crates stay in the same order, resulting in this new configuration:

        [D]
        [N]
    [C] [Z]
    [M] [P]
 1   2   3

Next, as both crates are moved from stack 2 to stack 1, they retain their order as well:

        [D]
        [N]
[C]     [Z]
[M]     [P]
 1   2   3

Finally, a single crate is still moved from stack 1 to stack 2, but now it's crate C that gets moved:

        [D]
        [N]
        [Z]
[M] [C] [P]
 1   2   3

In this example, the CrateMover 9001 has put the crates in a totally different order: MCD.

Before the rearrangement process finishes, update your simulation so that the Elves know where they should stand to be ready to unload the final supplies. After the rearrangement procedure completes, what crate ends up on top of each stack?

"""
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

