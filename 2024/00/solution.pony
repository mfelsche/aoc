use ".."
use "collections"
use "debug"
use "files"
use "itertools"

actor Solution is AocSolution
  let _env: Env

new create(env: Env) =>
    _env = env

  fun tag day(): U32 => 0


  be part1(notify: SolutionNotify tag) =>
    notify.fail(this, 1, "TBD")


  be part2(notify: SolutionNotify tag) =>
    notify.fail(this, 2, "TBD")


