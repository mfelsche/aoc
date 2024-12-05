use ".."
use "collections"
use "debug"

class Solution is AocSolution
  let _env: Env

  new create(env: Env) =>
    _env = env

  fun tag day(): U64 => 3


  fun ref part1(): String iso^ ? =>
    var result = U64(0)
    let splatted_m: USize = splat('m')
    let mul = U32('(lum') // reversed mul(
    for line in AOCUtils.get_input_lines("2024/03/input.txt", _env)? do
      let input: String val = consume line
      let input_array = input.array()
      var i = USize(0)

      while (input.size() - i) >= 8 do
        // tryin a swar parsing approach for finding a valid mul(
        try
          let haystack = 
            ifdef ilp32 then
              input_array.read_u32(i)?.bswap().usize()
            else
              input_array.read_u64(i)?.bswap().usize()
            end
          //Debug("chunk " + input.trim(i, i + 8))
          if has_zero_byte(haystack xor splatted_m) > 0 then
            //Debug("m @ " + input.trim(i, i + 8))
            // we have an m somewhere in there
            for _ in Range(0, i.bytewidth()) do
              let mul_chunk = input_array.read_u32(i)?
              if (mul_chunk xor mul) == 0 then
                //Debug("mul( @ " + input.trim(i, i + 20))
                // we have a full mul
                i = i + 4 // forward beyond mul(
                (let first_multiplier, let comma_offset) = extract_num(input, i, ',')
                if first_multiplier >= 0 then // valid
                  i = i + comma_offset + 1 // skip beyond comma or error
                  (let second_multiplier, let paren_offset) = extract_num(input, i, ')')
                  if second_multiplier >= 0 then
                    i = i + paren_offset + 1
                    //Debug(first_multiplier.string() + " * " + second_multiplier.string())
                    result = result + (first_multiplier * second_multiplier).u64()
                    break
                  end
                end
              else
                // no mul( at this place
                // skip 1 byte ahead
                i = i + 1
              end
            end
          else
            i = i + i.bytewidth()
          end
        else
          // at the end of the line
          break
        end
      end
      // we don't need to handle the last chunk as it cannot contain a valid mul(
    end
    result.string()


  fun tag has_zero_byte(v: USize): USize =>
    """
    Return 0 if there is no zero byte in `v`.
    Sets the highest bit in every byte to 1 where we have some bits set.
    """
    ifdef ilp32 then
      (v - 0x01010101) and ((not v) and 0x80808080)
    else
      (v - 0x0101010101010101) and ((not v) and 0x8080808080808080)
    end

  fun tag splat(byte: U8): USize =>
    ((not USize(0)) / 255) * byte.usize()

  fun tag extract_num(s: String val, idx: USize, delimiter: U8): (I32, USize) =>
    var i = USize(1)
    try
      while (idx + i) < s.size() do
        if s(idx + i)? == delimiter then
          //Debug(s.trim(idx, i))
          let num =
            try
              s.trim(idx, idx + i).i32()?
            else
              -1
            end
          return (num, i)
        end
        i = i + 1
      end
      (-1, 0)
    else
      (-1, 0)
    end

  fun ref part2(): String iso^ ? =>
    var result = U64(0)
    var enabled = true
    let splatted_m: USize = splat('m')
    let splatted_d: USize = splat('d')
    let mul = U32('(lum') // reversed mul(
    let do_cond = U32(')(od') // reversed do()
    let dont_cond_start = U32('\'nod')
    // with 1 overlapping
    let dont_cond_end = U32(')(t\'')
    for line in AOCUtils.get_input_lines("2024/03/input.txt", _env)? do
      let input: String val = consume line
      let input_array = input.array()
      var i = USize(0)

      while (input.size() - i) >= 8 do
        // tryin a swar parsing approach for finding a valid mul(
        try
          let haystack = 
            ifdef ilp32 then
              input_array.read_u32(i)?.bswap().usize()
            else
              input_array.read_u64(i)?.bswap().usize()
            end

          Debug("chunk " + input.trim(i, i + 8))
          if has_zero_byte(haystack xor splatted_d) > 0 then
            // we have a d
            for _ in Range(0, i.bytewidth()) do
              let do_chunk = input_array.read_u32(i)?
              if enabled then
                // look for don't, ignore everything else
                if (do_chunk xor dont_cond_start) == 0 then
                  i = i + 3 // overlapping check
                  let do_chunk_cont = input_array.read_u32(i)?
                  if (do_chunk_cont xor dont_cond_end) == 0 then
                    enabled = false
                    Debug("don't()")
                    break
                  else
                    i = i + 1
                  end
                else
                  i = i + 1
                end
              else
                // look for do, ignore everything else
                if (do_chunk xor do_cond) == 0 then
                  i = i + 4
                  enabled = true
                  Debug("do()")
                  break
                else
                  i = i + 1
                end
              end
            end
          elseif enabled and (has_zero_byte(haystack xor splatted_m) > 0) then
            // copied verbatim from part 1
            for _ in Range(0, i.bytewidth()) do
              let mul_chunk = input_array.read_u32(i)?
              if (mul_chunk xor mul) == 0 then
                //Debug("mul( @ " + input.trim(i, i + 20))
                // we have a full mul
                i = i + 4 // forward beyond mul(
                (let first_multiplier, let comma_offset) = extract_num(input, i, ',')
                if first_multiplier >= 0 then // valid
                  i = i + comma_offset + 1 // skip beyond comma or error
                  (let second_multiplier, let paren_offset) = extract_num(input, i, ')')
                  if second_multiplier >= 0 then
                    i = i + paren_offset + 1
                    Debug(first_multiplier.string() + " * " + second_multiplier.string())
                    result = result + (first_multiplier * second_multiplier).u64()
                    break
                  end
                end
              else
                // no mul( at this place
                // skip 1 byte ahead
                i = i + 1
              end
            end
          else
            i = i + i.bytewidth()
          end
        else
          break
        end
      end
    end

    result.string()


