use "files"
use "debug"
use @pony_os_errno[I32]()

primitive AOCUtils
  fun get_input_lines(path: String, env: Env): FileLines ? =>
    let file_path = FilePath(FileAuth(env.root), path, recover val FileCaps .> set(FileRead) .> set(FileStat) end )
    match OpenFile(file_path)
    | let file: File =>
      file.lines()
    | let _: FileEOF =>
      env.err.print("EOF")
      error
    | let _: FileOK =>
      env.err.print("OK") // weird
      error
    | let _: FileError =>
      env.err.print("Error opening " + path.string() + ". You might need to download the input and put it into input.txt")
      error
    | let _: FileBadFileNumber =>
      env.err.print("Bad file number")
      error
    | let _: FileExists =>
      env.err.print("Exists")
      error
    | let _: FilePermissionDenied =>
      env.err.print("Permission denied")
      error
    end

  fun get_input(path: String, env: Env): String iso^ ? =>
    let file_path = FilePath(FileAuth(env.root), path, recover val FileCaps .> set(FileRead) .> set(FileStat) end )
    match OpenFile(file_path)
    | let file: File =>
      let file_len = file.size()
      let buf = recover iso Array[U8].create(file_len) end
      while buf.size() < file_len do
        let data = file.read(file_len)
        if data.size() > 0 then
          buf.append(consume data)
        end
        if file.errno() isnt FileEOF then
          break
        end
        if file.errno() isnt FileOK then
          env.err.print("Error reading from file")
          error
        end
      end
      String.from_iso_array(consume buf)
    | let _: FileEOF =>
      env.err.print("EOF")
      error
    | let _: FileOK =>
      env.err.print("OK") // weird
      error
    | let _: FileError =>
      env.err.print("Error opening " + path.string() + ". You might need to download the input and put it into input.txt")
      error
    | let _: FileBadFileNumber =>
      env.err.print("Bad file number")
      error
    | let _: FileExists =>
      env.err.print("Exists")
      error
    | let _: FilePermissionDenied =>
      env.err.print("Permission denied")
      error
    end

// stolen from https://github.com/salty-blue-mango/roaring-pony
primitive BinarySearch
  fun reverse[T: Comparable[T] #read](needle: T, haystack: ReadSeq[T]): (USize, Bool) =>
    """
    Perform a binary search for `needle` on `haystack`.

    Returns the result as a 2-tuple of either:
    * the index of the found element and `true` if the search was successful, or
    * the index where to insert the `needle` to maintain a sorted `haystack` and `false`
    """
    try
      var i = USize(0)
      var l = USize(0)
      var r = haystack.size()
      var idx_adjustment: USize = 0
      while l < r do
        i = (l + r).fld(2)
        let elem = haystack(i)?
        match needle.compare(elem)
        | Greater =>
          idx_adjustment = 0
          r = i
        | Equal => return (i, true)
        | Less =>
          // insert index needs to be adjusted by 1 if greater
          idx_adjustment = 1
          l = i + 1
        end
      end
      (i + idx_adjustment, false)
    else
      // shouldnt happen
      Debug("invalid haystack access.")
      (0, false)
    end

