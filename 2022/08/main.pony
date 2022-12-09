"""
--- Day 8: Treetop Tree House ---

The expedition comes across a peculiar patch of tall trees all planted carefully in a grid. The Elves explain that a previous expedition planted these trees as a reforestation effort. Now, they're curious if this would be a good location for a tree house.

First, determine whether there is enough tree cover here to keep a tree house hidden. To do this, you need to count the number of trees that are visible from outside the grid when looking directly along a row or column.

The Elves have already launched a quadcopter to generate a map with the height of each tree (your puzzle input). For example:

30373
25512
65332
33549
35390

Each tree is represented as a single digit whose value is its height, where 0 is the shortest and 9 is the tallest.

A tree is visible if all of the other trees between it and an edge of the grid are shorter than it. Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.

All of the trees around the edge of the grid are visible - since they are already on the edge, there are no trees to block the view. In this example, that only leaves the interior nine trees to consider:

    The top-left 5 is visible from the left and top. (It isn't visible from the right or bottom since other trees of height 5 are in the way.)
    The top-middle 5 is visible from the top and right.
    The top-right 1 is not visible from any direction; for it to be visible, there would need to only be trees of height 0 between it and an edge.
    The left-middle 5 is visible, but only from the right.
    The center 3 is not visible from any direction; for it to be visible, there would need to be only trees of at most height 2 between it and an edge.
    The right-middle 3 is visible from the right.
    In the bottom row, the middle 5 is visible, but the 3 and 4 are not.

With 16 trees visible on the edge and another 5 visible in the interior, a total of 21 trees are visible in this arrangement.

Consider your map; how many trees are visible from outside the grid?


--- Part Two ---

Content with the amount of tree cover available, the Elves just need to know the best spot to build their tree house: they would like to be able to see a lot of trees.

To measure the viewing distance from a given tree, look up, down, left, and right from that tree; stop if you reach an edge or at the first tree that is the same height or taller than the tree under consideration. (If a tree is right on the edge, at least one of its viewing distances will be zero.)

The Elves don't care about distant trees taller than those found by the rules above; the proposed tree house has large eaves to keep it dry, so they wouldn't be able to see higher than the tree house anyway.

In the example above, consider the middle 5 in the second row:

30373
25512
65332
33549
35390

    Looking up, its view is not blocked; it can see 1 tree (of height 3).
    Looking left, its view is blocked immediately; it can see only 1 tree (of height 5, right next to it).
    Looking right, its view is not blocked; it can see 2 trees.
    Looking down, its view is blocked eventually; it can see 2 trees (one of height 3, then the tree of height 5 that blocks its view).

A tree's scenic score is found by multiplying together its viewing distance in each of the four directions. For this tree, this is 4 (found by multiplying 1 * 1 * 2 * 2).

However, you can do even better: consider the tree of height 5 in the middle of the fourth row:

30373
25512
65332
33549
35390

    Looking up, its view is blocked at 2 trees (by another tree with a height of 5).
    Looking left, its view is not blocked; it can see 2 trees.
    Looking down, its view is also not blocked; it can see 1 tree.
    Looking right, its view is blocked at 2 trees (by a massive tree of height 9).

This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for the tree house.

Consider each tree on your map. What is the highest scenic score possible for any tree?

"""

use ".."
use "debug"
use "itertools"
use "collections"

class ref RunState
  var max: I32 = -1 // smaller than all possible values

  fun ref is_visible_in_row(x: USize, y: USize, h: U8): Bool =>
    let th = h.i32()
    // check visibility from start of row
    // when the max increases, we are visible from the start
    if th > max then
      max = th
      true
    else
      false
    end

class Part1

  // global bitmap of visible trees
  var visible: Array[Array[Bool] ref] ref = visible.create(0)
  // count of visible trees
  var count: USize = 0

  let env: Env

  new create(env': Env) =>
    env = env'

  fun ref mark_tree_as_visible(x: USize, y: USize) ? =>
    // ensure we have enough bitmap for marking the current tree

    // if it hasen't been marked yet, it contributes to the count
    if (visible(y)?(x)? = true) == false then
      count = count + 1
    end

  fun ref look_at_trees(matrix: TreeMatrix, dims: (USize, USize)): USize ? =>
    // look over each row and column in two ways:
    // forward and backward
    // and apply the following algorhithm:
    // * keep the maximum value seen
    // * Whenever the maximum increases we have a visible tree from the end we
    //   started from, mark this one as "visible"
    // * combine the scores

    // runstates for looking at columns
    var column_states = Array[RunState].create(dims._2)
    var reverse_column_states = Array[RunState].create(dims._2)

    // runstates for looking at rows
    var row_states = Array[RunState].create(dims._1)
    var reverse_row_states = Array[RunState].create(dims._1)


    // one pass over the rows forward and reverse
    for y in Range[USize](0, dims._1, 1) do
      // prepare the visible tree matrix
      visible.push(Array[Bool].init(false, dims._2))
      // prepare the row runstates
      row_states.push(RunState)
      reverse_row_states.push(RunState)

      let row = matrix(y)?

      // forward
      for x in Range[USize](0, dims._2, 1) do
        // get the tree-height
        let h = row(x)?
        if row_states(y)?.is_visible_in_row(x, y, h) then
          mark_tree_as_visible(x, y)?
        end
      end

      // reverse
      for x in Reverse[USize](dims._2 - 1, 0, 1) do
        let h = row(x)?
        if reverse_row_states(y)?.is_visible_in_row(x, y, h) then
          mark_tree_as_visible(x, y)?
        end
      end

      // first and last columns always visible
      mark_tree_as_visible(0, y)?
      mark_tree_as_visible(dims._2 - 1, y)?
    end

    // iterate the columns forward and reverse
    for x in Range[USize](0, dims._2, 1) do
      column_states.push(RunState)
      reverse_column_states.push(RunState)

      // foward
      for y in Range[USize](0, dims._1, 1) do
        let h = matrix(y)?(x)?
        if column_states(x)?.is_visible_in_row(x, y, h) then
          mark_tree_as_visible(x, y)?
        end
      end

      // reverse
      for y in Reverse[USize](dims._1 - 1, 0, 1) do
        let h = matrix(y)?(x)?
        if reverse_column_states(x)?.is_visible_in_row(x, y, h) then
          mark_tree_as_visible(x, y)?
        end
      end

      // first row and last row always visible
      mark_tree_as_visible(x, 0)?
      mark_tree_as_visible(x, dims._1 - 1)?
    end
    count

  fun debug_trees() =>
    ifdef debug then
      for row in visible.values() do
        for v in row.values() do
          env.out.write(if v then "x" else "o" end)
        end
        env.out.print("")
      end
    end

class ref ScenicScore
  var up: USize = 0
  var down: USize = 0
  var left: USize = 0
  var right: USize = 0

  new ref create() => None

  fun score(): USize =>
    up * down * left * right

class Part2
  """
  calculate the scenic score for each tree

  How many trees in each direction until we hit a larger or equal tree
  """
  var scores: Array[Array[ScenicScore] ref] ref

  new ref look_at_trees(matrix: TreeMatrix, dims: (USize, USize)) ? =>

    // initialize scores
    let s = Array[Array[ScenicScore] ref].create(dims._1)
    for y in Range[USize](0, dims._1, 1) do
      s.push(Array[ScenicScore ref].create(dims._2))
      for x in Range[USize](0, dims._2, 1) do
        s(y)?.push(ScenicScore)
      end
    end
    scores = s

    // look at the rows to get the left and right scenic scores
    for y in Range[USize](0, dims._1, 1) do

      let row = matrix(y)?

      // forward - calculate the right score
      for x in Range[USize](0, dims._2, 1) do
        let tree = row(x)?
        // take x as the last index
        // for all previous trees, when it is smaller or equal, set the distance
        var scored = false
        var z = x + 1
        while z < dims._2 do
          let ptree = row(z)?
          if ptree >= tree then
            scores(y)?(x)?.right = z - x
            scored = true
            break
          end
          z = z + 1
        end
        if not scored then
          // we fell through, we can see to the edge
          scores(y)?(x)?.right = (dims._2 - 1) - x
        end
      end

      // backward - calculate the left score
      for x in Reverse[USize](dims._2 - 1, 0, 1) do
        let tree = row(x)?
        if x > 0 then
          var z = x - 1
          var scored = false
          while z > 0 do
            let ptree = row(z)?
            if ptree >= tree then
              scores(y)?(x)?.left = x - z
              scored = true
              break
            end
            z = z - 1
          end
          if not scored then
            // we fell through, we can see to the edge
            scores(y)?(x)?.left = x
          end
        end
      end
    end

    // columns
    for x in Range[USize](0, dims._2, 1) do
      // forward to calculate the down score
      for y in Range[USize](0, dims._1, 1) do
        let tree = matrix(y)?(x)?
        var z = y + 1
        var scored = false
        while z < dims._1 do
          let ptree = matrix(z)?(x)?
          if ptree >= tree then
            scores(y)?(x)?.down = z - y
            scored = true
            break
          end
          z = z + 1
        end
        if not scored then
          // we fell through, we can see to the edge
          scores(y)?(x)?.down = (dims._1 - 1) - y
        end
      end

      // backward to calculate the up score
      for y in Reverse[USize](dims._1 - 1, 0, 1) do
        let tree = matrix(y)?(x)?
        if y > 0 then
          var z = y - 1
          var scored = false
          while z > 0 do
            let ptree = matrix(z)?(x)?
            if ptree >= tree then
              scores(y)?(x)?.up = y - z
              scored = true
              break
            end
            z = z - 1
          end
          if not scored then
            // we fell through, we can see to the edge
            scores(y)?(x)?.up = y
          end
        end
      end
    end

  fun max_score(): USize =>
    // calculate the final scores
    var max_score': USize = 0
    for score_row in scores.values() do
      for score in score_row.values() do
        max_score' = max_score'.max(score.score())
      end
    end
    max_score'

  fun debug_scores(out: OutStream) =>
    for score_row in scores.values() do
      let iter = score_row.values()
      for score in iter do
        out.write("[u:" + score.up.string() + " d:" + score.down.string() + " l:" + score.left.string() + " r:" + score.right.string() + "]")
        if iter.has_next() then
          out.write(", ")
        end
      end
      out.print("")
    end


type TreeMatrix is Array[Array[U8] val] val


actor Main

  fun print_matrix(matrix: TreeMatrix, out: OutStream) =>
    for row in matrix.values() do
      for tree in row.values() do
        out.write(recover val String.from_utf32(tree.u32()) end)
      end
      out.print("")
    end

  new create(env: Env) =>
    try
      let input_file =
        try
          env.args(1)?
        else
          "input.txt"
        end
      // construct the matrix
      let matrix: TreeMatrix =
        recover val
          Iter[String iso^](AOCUtils.get_input_lines(input_file, env)?)
            .map[String val]({(iso_line) => recover val iso_line end})
            .filter({(line) => line.size() > 0})
            .map[Array[U8] val]({(s) => s.array()})
            .collect[Array[Array[U8] val] ref](Array[Array[U8] val](32))
        end
      let dims = (matrix.size(), matrix(0)?.size())
      //env.out.print("Matrix size: y: " + dims._1.string() + " x: " + dims._2.string())
      //print_matrix(matrix, env.out)

      let part1 = Part1(env)
      let count = part1.look_at_trees(matrix, dims)?
      //part1.debug_trees()
      env.out.print("Part 1: " + count.string())

      let part2 = Part2.look_at_trees(matrix, dims)?
      let max_scenic_score = part2.max_score()
      //part2.debug_scores(env.out)
      env.out.print("Part 2: " + max_scenic_score.string())

    else
      env.exitcode(1)
    end
