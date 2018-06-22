module PT = Proof_type
open PT
module TU = Term_unification
open TU
open Core.Std

type formula_substitution = (string * formula)