"""
--- Day 3: Rucksack Reorganization ---

One Elf has the important job of loading all of the rucksacks with supplies for the jungle journey. Unfortunately, that Elf didn't quite follow the packing instructions, and so a few items now need to be rearranged.

Each rucksack has two large compartments. All items of a given type are meant to go into exactly one of the two compartments. The Elf that did the packing failed to follow this rule for exactly one item type per rucksack.

The Elves have made a list of all of the items currently in each rucksack (your puzzle input), but they need your help finding the errors. Every item type is identified by a single lowercase or uppercase letter (that is, a and A refer to different types of items).

The list of items for each rucksack is given as characters all on a single line. A given rucksack always has the same number of items in each of its two compartments, so the first half of the characters represent items in the first compartment, while the second half of the characters represent items in the second compartment.

For example, suppose you have the following list of contents from six rucksacks:

vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw

    The first rucksack contains the items vJrwpWtwJgWrhcsFMMfFFhFp, which means its first compartment contains the items vJrwpWtwJgWr, while the second compartment contains the items hcsFMMfFFhFp. The only item type that appears in both compartments is lowercase p.
    The second rucksack's compartments contain jqHRNqRjqzjGDLGL and rsFMfFZSrLrFZsSL. The only item type that appears in both compartments is uppercase L.
    The third rucksack's compartments contain PmmdzqPrV and vPwwTWBwg; the only common item type is uppercase P.
    The fourth rucksack's compartments only share item type v.
    The fifth rucksack's compartments only share item type t.
    The sixth rucksack's compartments only share item type s.

To help prioritize item rearrangement, every item type can be converted to a priority:

    Lowercase item types a through z have priorities 1 through 26.
    Uppercase item types A through Z have priorities 27 through 52.

In the above example, the priority of the item type that appears in both compartments of each rucksack is 16 (p), 38 (L), 42 (P), 22 (v), 20 (t), and 19 (s); the sum of these is 157.

Find the item type that appears in both compartments of each rucksack. What is the sum of the priorities of those item types?

--- Part Two ---

As you finish identifying the misplaced items, the Elves come to you with another issue.

For safety, the Elves are divided into groups of three. Every Elf carries a badge that identifies their group. For efficiency, within each group of three Elves, the badge is the only item type carried by all three Elves. That is, if a group's badge is item type B, then all three Elves will have item type B somewhere in their rucksack, and at most two of the Elves will be carrying any other item type.

The problem is that someone forgot to put this year's updated authenticity sticker on the badges. All of the badges need to be pulled out of the rucksacks so the new authenticity stickers can be attached.

Additionally, nobody wrote down which item type corresponds to each group's badges. The only way to tell which item type is the right one is by finding the one item type that is common between all three Elves in each group.

Every set of three lines in your list corresponds to a single group, but each group can have a different badge item type. So, in the above example, the first group's rucksacks are the first three lines:

vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg

And the second group's rucksacks are the next three lines:

wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw

In the first group, the only item type that appears in all three rucksacks is lowercase r; this must be their badges. In the second group, their badge item type must be Z.

Priorities for these items must still be found to organize the sticker attachment efforts: here, they are 18 (r) for the first group and 52 (Z) for the second group. The sum of these is 70.

Find the item type that corresponds to the badges of each three-Elf group. What is the sum of the priorities of those item types?


"""

use ".."
use "collections"
use "debug"
use "format"
use "itertools"

primitive Priorities
  fun apply(char: U8): U64 =>
    U64.from[U8](
      if (char < 'a') then
        char - 38
      else
        char - 96
      end
    )

primitive Part1
  fun compartment_priority(line: String val): U64 ? =>
    let split_point = (line.size() / 2).isize()
    // firts sort both arrays
    let arr1: Array[U8] ref = Sort[Array[U8], U8](line.substring(0, split_point).iso_array())
    let arr2: Array[U8] ref = Sort[Array[U8], U8](line.substring(split_point).iso_array())

    // advance the iter with the smaller value until we find a match or
    // exhaust one of both
    let iter1 = arr1.values()
    let iter2 = arr2.values()

    var c1 = iter1.next()?
    var c2 = iter2.next()?
    let similar: U8 =
      while true do
        if (c1 < c2) and iter1.has_next() then
          c1 = iter1.next()?
        elseif c1 == c2 then
          break c1
        elseif iter2.has_next() then
          c2 = iter2.next()?
        else
          Debug(arr1)
          Debug(arr2)
          error
        end
      else
        U8.max_value()
      end

    let priority = Priorities(similar)
    //Debug(String.from_utf32(similar.u32()) + ": " + priority.string())
    priority


primitive Part2
  fun group_priority(group: Array[String val] ref): U64 ? =>
    // TODO: abstract away into function handlign an arbitrary array of
    // pre-sorted iters
    let iter1 = Sort[Array[U8], U8](group(0)?.array().clone()).values()
    let iter2 = Sort[Array[U8], U8](group(1)?.array().clone()).values()
    let iter3 = Sort[Array[U8], U8](group(2)?.array().clone()).values()

    var c1 = iter1.next()?
    var c2 = iter2.next()?
    var c3 = iter3.next()?

    let similar: U8 =
      while true do
        if (c1 == c2) and (c2 == c3) then
          break c1
        elseif ((c1 < c2) or (c1 < c3)) and iter1.has_next() then
          c1 = iter1.next()?
        elseif ((c2 < c1) or (c2 < c3)) and iter2.has_next() then
          c2 = iter2.next()?
        elseif ((c3 < c1) or (c3 < c2)) and iter3.has_next() then
          c3 = iter3.next()?
        else
          error
        end
      else
        U8.max_value() // shouldn't happen
      end

    let priority = Priorities(similar)
    //Debug(String.from_utf32(similar.u32()) + "(" + similar.string() + "): " + priority.string())
    priority


actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var group_sum = U64(0)
      var compartment_sum = U64(0)
      let group: Array[String val] ref = Array[String val](3)
      for line in lines do
        if line.size() == 0 then continue end
        let line_val = recover val (consume line) end
        // Part1
        compartment_sum = compartment_sum + Part1.compartment_priority(line_val)?

        // Part2
        group.push(line_val)
        if group.size() == 3 then
          let priority = Part2.group_priority(group)?
          group_sum = group_sum + priority
          group.clear()
        end
      end
      env.out.print("Part 1: " + compartment_sum.string())
      env.out.print("Part 2: " + group_sum.string())
    else
      env.exitcode(1)
    end
