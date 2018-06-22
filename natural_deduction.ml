open Proof_type
open Core.Std
open Rules


module NatDed :
sig
  val proof :
    ?known_truth: formula list ->
    Core.Std.Out_channel.t ->
    proof ->
    term list ->
    bool
end  
=
struct
  exception IncorrectProof of int
  
  let rec _proof line_number (Proof(l)) known_truth boxes terms ~outx =
    let is_item_OK ln truth item boxes terms =
      match item with
      | Prove_it(f) -> 
        (match Proof_assistant.infer f truth with 
         | Some(l) -> 
           Printing.print_prove_it f  l ~outx ;  
           ( f:: truth, boxes) 
         | None -> raise (IncorrectProof(ln)))
      | Formula(f) ->
        if Rules.inferable f truth boxes  terms
        then ( f:: truth, boxes) 
        else raise (IncorrectProof(ln))
      | Hypothesis(assumption, l2) ->
        match assumption with
        | Form(form) | Fresh_Form(_, form) ->
          if _proof (ln+1) l2 (form::truth) boxes terms ~outx
          then (truth, hypothesis_to_box item :: boxes )
          else raise (IncorrectProof(ln))
        | Fresh(_) ->
          if _proof (ln+1) l2 truth boxes terms ~outx
          then (truth, hypothesis_to_box item :: boxes )
          else raise (IncorrectProof(ln))
    in
    let _ = List.foldi l ~init:(known_truth, boxes)
        ~f:(fun i (truth, boxes) item -> is_item_OK (line_number + i) truth item boxes terms)
    in true

  let proof ?(known_truth=[]) outx p terms  =
    try _proof 0 p known_truth [] (List.dedup terms) ~outx with
      IncorrectProof(line_number) ->
      Out_channel.output_string outx @@ "  Błąd w dowodzie w linii numer " ^  string_of_int line_number ^ "\n";
      false
end

