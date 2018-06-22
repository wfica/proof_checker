open Proof_type
open Core.Std


module Rules 
  :  
  sig
    val inferable: formula ->  formula list -> box list ->  term list -> bool
  end 
=
struct 
  let introAll (box : box) x f = 
    match fst box with
    | Form(_) | Fresh_Form(_) -> false
    | Fresh(x0) ->  substitute x f ~subs:(Var(x0)) = Some (snd box)

  let introduction (goal : formula) (truth : formula list) (boxes : box list) (terms : term list) = 
    let is_true = List.mem truth in 
    let in_boxes = List.mem boxes in 
    match goal with 
    | And(x, y) -> is_true x && is_true y
    | Or(x, y) -> is_true x || is_true y 
    | Impl(x, y) -> in_boxes (Form(x), y) 
    | Const(x) -> x 
    | Not(x) -> in_boxes (Form x, Const(false))
    | Iff(x, y) -> is_true (Impl (x, y) ) &&  is_true (Impl(y, x))
    | Exists(x, f) -> List.exists terms 
                        ~f:(fun subs -> match substitute x f ~subs with 
                            | Some(res) -> res |> is_true 
                            | None -> false )
    | All(x, f) -> List.exists boxes ~f:(fun box -> introAll box x f) 
    | Pred(_) -> is_true goal 

  let elimExists (box : box) x f goal =
    if snd box <> goal then false 
    else 
      match fst box with
      | Form(_) | Fresh(_) -> false
      | Fresh_Form(x0, subed) -> substitute x f ~subs:(Var x0) = Some subed 


  let elimination (goal : formula) (truth : formula list) (boxes : box list) (terms : term list) =
    let is_true = List.mem truth in 
    let in_boxes = List.mem boxes in 
    let eliminate formula goal = 
      match formula with 
      | And(x, y) -> x = goal || y = goal
      | Or(x, y) -> in_boxes (Form x, goal)  && in_boxes (Form y, goal) 
      | Impl(x, y) -> y =  goal && is_true x 
      | Const(x) -> x = false
      | Pred(_) -> false
      | Iff(x, y) -> x = goal && is_true y || y = goal && is_true x  
      | Not(x)  -> 
        if goal = Const(false) then is_true x 
        else (match x with 
            | Not(y) -> y = goal 
            | _ -> false)
      | Exists(x, f) -> List.exists boxes ~f:(fun box -> elimExists box x f goal)
      | All (x, f) -> List.exists terms ~f:(fun subs ->  substitute x f ~subs = Some goal )
    in 
    List.exists truth ~f:(fun f -> eliminate f goal)

  let inferable (goal : formula) (truth : formula list) (boxes : box list) (terms : term list) : bool = 
    List.mem truth goal || 
    introduction goal truth boxes terms || 
    elimination goal truth boxes terms
end 