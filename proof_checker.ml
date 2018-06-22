open Core.Std
open Lexing
open Proof_type
open Natural_deduction



let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let append_some x ~l =
  match x with 
  | None -> l
  | Some e -> e::l

let parse_with_error lexbuf =
  try Parser.prog Lexer.read lexbuf with
  | Lexer.SyntaxError msg ->
    fprintf stderr "%a: %s\n" print_position lexbuf msg;
    [],[]
  | Parser.Error ->
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)

let verify index (Task(task_name, goal, proof) as task) known_truth terms outx =
  Out_channel.output_string outx @@ string_of_int index ^ ":" ;
  match is_task_valid task with
  | false -> 
    Out_channel.output_string outx @@ "  Dowód " ^ task_name ^ " błędny - nie dowodzi celu!\n" ; None
  | true -> 
    if NatDed.proof ~known_truth outx proof terms 
    then let _ = Out_channel.output_string outx @@ "    Dowód " ^ task_name ^ " poprawny.\n" in Some goal
    else let _ = Out_channel.output_string outx @@ "    Dowód " ^ task_name ^ " błędny!\n" in None



let solve tasks outFile axioms = 
  let axioms_terms = terms_of_axioms axioms in 
  let outx = Out_channel.create outFile in 
  let proccess_task i truth task = 
    verify i task truth (axioms_terms @ terms_of_task task)  outx |> append_some ~l:truth   in 
  let _ = List.foldi tasks ~init:axioms ~f:proccess_task  in 
  Out_channel.close outx 

let parse_inFile inFile outFile () =
  let inx = In_channel.create inFile in 
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = inFile };
  let (axioms, tasks) = parse_with_error lexbuf in
  In_channel.close inx ;
  solve tasks outFile axioms


  
(* let _ = parse_inFile "tests/in" "results/out" ()  *)



let () =
  Command.basic 
    ~summary:"Proof checker - Wojtek Fica"
    ~readme:(fun () -> "usage:\n arguments: input_file output_file")
    Command.Spec.(empty +> anon ("in" %: file ) +> anon ("out" %: file) )  
    parse_inFile 
  |> Command.run