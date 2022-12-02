use "files"
use @pony_os_errno[I32]()

primitive AOCUtils
  fun get_input_lines(path: String, env: Env): FileLines ? =>
    let file_path = FilePath(FileAuth(env.root), path, recover val FileCaps .> all() end )
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
      env.err.print("Error")
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
