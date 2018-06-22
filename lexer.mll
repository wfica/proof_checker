{
open Lexing
open Parser

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
  
let rec get_var_id str = 
  let open Core.Std.String in 
  match chop_prefix str ~prefix:"A ",chop_prefix str ~prefix:"E ",chop_prefix str ~prefix:" "  with
  | Some(c), _, _ | _, Some(c), _ | _, _, Some(c) -> get_var_id c
  | None, None, None -> str

}


let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = ['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* 
let name = (['B'-'D'] | ['F' - 'Z']) ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let all = 'A' ' '+ id
let exists = 'E' ' '+ id

rule read =
  parse
  | white      { read lexbuf }
  | newline    { next_line lexbuf; read lexbuf }
  | "goal"     { GOAL }
  | "proof"    { BEGIN_PROOF }
  | "end."     { END }
  | "axioms"   { AXIOMS }
  | "fresh"    { FRESH }
  | "prove_it" { PROVE_IT }
  | '{'        { CURLY_LEFT }
  | '}'        { CURLY_RIGHT }
  | 'T'        { TRUE }
  | 'F'        { FALSE }
  | "/\\"      { AND }
  | "\\/"      { OR }
  | '~'        { NOT }
  | "=>"       { IMPL }
  | "<=>"      { IFF }
  | ','        { COMMA }
  | ':'        { COLON }
  | ';'        { SEMI_COLON }
  | '('        { LEFT_BRACK }
  | ')'        { RIGHT_BRACK }
  | '['        { LEFT_SQUARE_BRACK }
  | ']'        { RIGHT_SQUARE_BRACK }
  | name       { NAME (Lexing.lexeme lexbuf) }
  | id         { VARIABLE (Lexing.lexeme lexbuf) }
  | all        { ALL ( Lexing.lexeme lexbuf |>  get_var_id) }
  | exists     { EXISTS ( Lexing.lexeme lexbuf |>  get_var_id) }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof        { EOF }
