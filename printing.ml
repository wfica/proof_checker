open Core.Std
open Proof_type

let rec print_term ?(outx=Out_channel.stdout) t  =
  let print =  Out_channel.output_string outx in 
  match t with
  | Var(x) -> print x 
  | Fun(f, l) -> print (f^"(")  ; List.iter l ~f:(print_term ~outx); print ")"


let rec print_formula ?(outx=Out_channel.stdout) f  = 
  let print =  Out_channel.output_string outx in 
  match f with 
  | Pred(p, l) -> if l = [] then  print p  else  (print (p^"("); List.iter l ~f:(print_term ~outx) ; print ")" )
  | Const(true) -> print "T" 
  | Const(false) -> print "F" 
  | Not(f) -> print "~(" ;  print_formula ~outx  f ; print ")"
  | And(f1, f2) -> print "AND("; print_formula ~outx f1 ; print ", " ; print_formula ~outx f2 ; print ")"
  | Or(f1, f2) -> print "Or("; print_formula ~outx f1 ; print ", " ; print_formula ~outx f2 ; print ")"
  | Impl(f1, f2) -> print "Impl("; print_formula ~outx f1 ; print ", " ; print_formula ~outx f2 ; print ")"
  | Iff(f1, f2) -> print "Iff("; print_formula ~outx f1 ; print ", " ; print_formula ~outx f2 ; print ")"
  | All(x, f) -> print ("A "^ x^" ") ; print_formula f ~outx
  | Exists(x, f) -> print ("E "^ x^" ") ; print_formula f ~outx

let print_assumption ?(outx=Out_channel.stdout) a  =
  let print =  Out_channel.output_string outx in 
  match a with 
  | Form(f) -> print_formula f ~outx
  | Fresh(var) -> print ("fresh "^var^" ")
  | Fresh_Form (var, f) -> print ("fresh "^var^" ") ; print_formula f ~outx

let rec print_proof ?(outx=Out_channel.stdout) (Proof(proof))  =
  let print =  Out_channel.output_string outx in 
  let  print_proof_item ~outx item  =
    match item with 
    | Formula(f) -> print_formula f ~outx 
    | Prove_it(f) -> print "!{ "; print_formula f ~outx; print " }!" 
    | Hypothesis(a, p) ->  print "[ "; print_assumption a ~outx; print " : "; print_proof p ~outx; print " ]" 
  in 
  List.iter proof ~f:(print_proof_item ~outx); print ";\n" 

let rec output_task_list ?(outx=Out_channel.stdout)   task_list  = 
  let print =  Out_channel.output_string outx in
  match task_list with 
  | [] -> () 
  | (Task(id, target, proof) )::tl ->   
    print (id^"\n") ;
    print_formula  target ~outx ;
    print "\n" ; 
    print_proof  proof ~outx; print "------------\n";
    output_task_list  tl ~outx

let print_formula_list ?(outx=Out_channel.stdout)  l  =
  let print =  Out_channel.output_string outx in
  let rec aux l =
    match l with 
    | [] -> ()
    | hd::[] -> print_formula hd ~outx ; print ".\n"
    | hd::tl -> print_formula hd ~outx ; print ";\n" ; aux tl
  in aux l  

let print_prove_it ?(outx=Out_channel.stdout) f l = 
  let print =  Out_channel.output_string outx in
  print "\nDowód: " ;
  print_formula f ~outx ;
  print "\n";
  print_formula_list l ~outx ;
  print "\n"
