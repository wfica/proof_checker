open Proof_type
open Core.Std
open Rules

type impl_t = formula * formula 

let infer ?(rec_depth = 3)  (f : formula) (truth : formula list ) : formula list option  = 
  let rec aux rec_depth f truth (true_impls : impl_t list ) acc = 
    if rec_depth = 0 then None else
    if List.mem truth f then Some(f :: acc ) else 
      let poss = List.filter true_impls ~f:(fun (_, b) -> b = f ) in 
      let answers = List.filter_map poss ~f:(fun (a, b) -> aux (rec_depth - 1) a truth true_impls ((Impl(a, b)) :: acc) ) in 
      let sorted = List.sort ~cmp:(fun a b -> List.length a - List.length b ) answers in 
      match sorted with 
      | [] -> None 
      | hd::_ -> Some hd 
  in aux rec_depth f truth (List.filter_map truth ~f:(fun form -> match form with Impl(a,b) -> Some (a, b) | _ ->  None ) ) []