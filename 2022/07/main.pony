use ".."
use "collections"


// build a directory tree with files in each node

class ref Directory
  """
  Representing a directory node in the directory tree
  """
  let _name: String
  let _parent: (Directory ref | None)
  let _dirs: Map[String, Directory] ref = _dirs.create()
  let _files: Map[String, USize] ref = _files.create()
  var _size: USize = 0

  new ref root() =>
    _name = "/"
    _parent = None

  new ref child(name': String, parent': Directory ref) =>
    _name = name'
    _parent = parent'

  fun ref add_child(name': String): Directory ref =>
    let c = Directory.child(name', this)
    _dirs.insert_if_absent(name', c)

  fun ref add_file(name': String, size': USize) =>
    // only to avoid duplications
    if not _files.contains(name') then
      _size = _size + size'
      // apply size to all parents
      var dir = _parent
      while true do
        match dir
        | let d: Directory ref =>
          d._size = d._size + size'
          dir = d._parent
        | None => break
        end
      end
      _files.insert(name', size')
    end

  fun ref parent(): Directory ref ? =>
    match _parent
    | let p: Directory => p
    | None => error
    end

  fun ref get_root(): Directory ref =>
    match _parent
    | let p: Directory => p.get_root()
    | None => this
    end

  fun box size(): USize =>
    _size

  fun box name(): String =>
    _name

  fun box children(): Iterator[Directory box] =>
    _dirs.values()

trait DirWalker
  fun ref walk(dir: Directory box) =>
    visit_dir(dir)
    for sub_dir in dir.children() do
      walk(sub_dir)
    end

  fun ref visit_dir(dir: Directory box)

class ref SumWalker is DirWalker
  var sum: USize
  let max: USize

  new ref create() =>
    sum = 0
    max = 100000

  fun ref visit_dir(dir: Directory box) =>
    if dir.size() <= max then
      sum = sum + dir.size()
    end

class ref MinWalker is DirWalker
  let current_used: USize
  let goal: USize = 40000000 // used space
  var min: (Directory box | None) = None
  var min_value: ISize = ISize.max_value()

  new ref create(current': USize) =>
    current_used = current'

  fun ref visit_dir(dir: Directory box) =>
    // minimize the diff between the goal and what space we would free
    let diff: ISize = goal.isize() - (current_used - dir.size()).isize()
    if (diff >= 0) and (diff < min_value) then
      min = dir
      min_value = diff
    end



actor Main
  new create(env: Env) =>
    try
      let lines = AOCUtils.get_input_lines("input.txt", env)?
      var current_dir: Directory = Directory.root()

      // construct the directory tree
      for line in lines do
        if line.size() == 0 then
          continue
        end
        let line': String val = consume line
        match line'(0)?
        | '$' =>
          let splitted = line'.substring(2).split_by(" ", 2)
          match splitted(0)?
          | "cd" =>
            let cd_arg' = match splitted(1)?
            | ".." =>
              current_dir = current_dir.parent()?
            | "/" =>
              current_dir = current_dir.get_root()
            | let dir: String =>
              current_dir = current_dir.add_child(dir)
            end
          | "ls" => None // we can switch to parsing a listing here, but i am too lazy
          end

        | 'd' =>
          // Directory listing
          let splitted = line'.split_by(" ", 2)
          let dir_name = splitted(1)?
          // add the child, as we might just get to know it here, but dont cd into it
          current_dir.add_child(dir_name)

        | let c: U8 if (c >= '0') and (c <= '9') =>
          // file listing
          let splitted = line'.split_by(" ", 2)
          let size = splitted(0)?.usize()?
          let file_name = splitted(1)?
          current_dir.add_file(file_name, size)
        end
      end

      env.out.print("Part 1")
      let root = current_dir.get_root()
      // now walk the dirs and sum
      let walker = SumWalker
      walker.walk(root)
      env.out.print(walker.sum.string())

      // part 2
      env.out.print("Part 2")
      let min_walker = MinWalker.create(root.size())
      min_walker.walk(root)
      match min_walker.min
      | let d: Directory box =>
        env.out.print(d.size().string())
      | None =>
        env.err.print("No min dir found")
      end

    else
      env.exitcode(0)
    end
