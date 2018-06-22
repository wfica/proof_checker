module PT = Proof_type
open PT
open Core.Std


(* terms substitution heavily based on:
https://www.cs.cornell.edu/courses/cs3110/2011sp/Lectures/lec26-type-inference/type-inference.htm  *)

type term_substitution = (string * term ) list

(* check if variable x occurs in term t*)
let rec occurs (x: string) (t: term) : bool =
  match t with
  | Var(y) -> y = x
  | Fun(_, l) -> List.exists l ~f:(occurs x)  

(* substitute term s for all occurences of variable x in term t*)
let rec subst (s: term) (x : string ) (t : term ) : term =
  match t with 
  | Var(y) -> if y = x then s else t
  | Fun(f, l) -> Fun(f, List.map l ~f:(subst s x) )

(* apply a substitution right to left *)
let apply (s: term_substitution) (t: term) : term = 
  List.fold_right s ~init:t ~f:(fun (id, sub) acc -> subst sub id acc )

(* unify one pair *)
let rec unify_one (s: term) (t: term) : term_substitution =
  match s, t with 
  | Var(x), Var(y) -> if x = y then [] else [(x, t)]
  | Fun(f, fa), Fun(g, ga) ->
    if f = g && List.length fa = List.length ga
    then unify (List.zip_exn fa ga)
    else failwith "not unifable: head sybmol conflict (name or arity)"
  | (Fun(_,_) as t), Var(x) | Var(x), (Fun(_,_) as t) ->
    if occurs x t 
    then failwith "not unifable: circularity"
    else [(x, t)]
  
(* unif a list of pairs *)
and unify ( l : (term *  term ) list) : term_substitution = 
  match l with
  | [] -> []
  | (x, y)::tl -> 
    let s2 = unify tl in 
    let s1 = unify_one (apply s2 x) (apply s2 y) in
    s1 @ s2  

  
let test = 
  let t1 = Fun("f", [Var("x"); Fun("g", [Var("y")])]) in 
  let t2 = Fun("f", [Fun("g", [Var("z")]); Var("w")]) in 
  let subs  = unify [t1, t2] in 
  subs
