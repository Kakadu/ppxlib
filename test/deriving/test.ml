#use "topfind";;
#require "base";;
#load "ppxlib_metaquot_lifters.cmo";;
#load "ppxlib_metaquot.cmo";;

open Ppxlib


let foo =
  Deriving.add "foo"
    ~str_type_decl:(Deriving.Generator.make_noarg
                      (fun ~loc ~path:_ _ -> [%str let x = 42]))
[%%expect{|
val foo : Ppxlib.Deriving.t = <abstr>
|}]

let bar =
  Deriving.add "bar"
    ~str_type_decl:(Deriving.Generator.make_noarg
                      ~deps:[foo]
                      (fun ~loc ~path:_ _ -> [%str let () = Printf.printf "x = %d\n" x]))
[%%expect{|
val bar : Ppxlib.Deriving.t = <abstr>
|}]

type t = int [@@deriving bar]
[%%expect{|
File "test/deriving/test.ml", line 26, characters 25-28:
Error: Deriver foo is needed for bar, you need to add it before in the list
|}]

type t = int [@@deriving bar, foo]
[%%expect{|
File "test/deriving/test.ml", line 32, characters 25-33:
Error: Deriver foo is needed for bar, you need to add it before in the list
|}]

type t = int [@@deriving foo, bar]
[%%expect{|
type t = int
val x : int = 42
|}]
