app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import cli.Stdout
import cli.Arg exposing [Arg]

main! : List Arg => Result {} _
main! = |_args|
    foo = foobar("ABC ")
    Stdout.line!("Hello, {foo}!")

foobar: Str -> Str
foobar = |s| s + "foobar"
