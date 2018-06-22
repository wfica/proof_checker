open Core.Std
open Lexing

let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.prog Lexer.read lexbuf with
  | Lexer.SyntaxError msg ->
    fprintf stderr "%a: %s\n" print_position lexbuf msg;
    [], []
  | Parser.Error ->
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)

let parse_and_print lexbuf =
  match parse_with_error lexbuf with
  | [], []-> ()
  | _ as l -> 
  printf "axioms:\n" ;
  List.iter (fst l ) ~f:( fun f -> Printing.print_formula f  ; printf "\n" ) ;
  printf "\ntasks:\n " ; 
  Printing.output_task_list (snd l ) 


let loop filename () =
  let inx = In_channel.create filename in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  parse_and_print lexbuf;
  In_channel.close inx

let () =
  Command.basic ~summary:"Parse and display proof"
    Command.Spec.(empty +> anon ("filename" %: file))
    loop 
  |> Command.run

