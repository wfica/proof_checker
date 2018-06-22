%{
open Proof_type
%}

%token <string> NAME     /* name of a predicate starting with upper-case letter except for 'A' and 'E' */
%token <string> VARIABLE /* name of a variable or a goal or a function starting with lower-case letter  */
%token AXIOMS
%token GOAL
%token BEGIN_PROOF
%token END
%token TRUE
%token FALSE
%token AND
%token OR
%token NOT
%token IMPL
%token IFF
%token COLON
%token SEMI_COLON
%token LEFT_BRACK
%token RIGHT_BRACK
%token LEFT_SQUARE_BRACK
%token RIGHT_SQUARE_BRACK
%token EOF

%token <string> ALL
%token <string> EXISTS
%token COMMA
%token FRESH

%token CURLY_LEFT
%token CURLY_RIGHT
%token PROVE_IT

%left IFF  /* lowest precedence  */
%right IMPL
%left OR
%left AND
%nonassoc NOT ALL EXISTS


%start <(Proof_type.formula list) * (Proof_type.task list)> prog

%%
prog:
  | tl = list(task) EOF { ([],tl) };
  | AXIOMS; COLON; ax = separated_list(SEMI_COLON, formula) ;  
                   tl = list(task) EOF { (ax , tl) };


task:
  GOAL; task_name = VARIABLE ; COLON;  goal = formula;
  BEGIN_PROOF;
  pil = proof;
  END                                               { Task( task_name, goal, pil) };
  
term: 
  | v = VARIABLE                                                           { Var(v) }
  | func = VARIABLE; LEFT_BRACK; l = separated_list(COMMA, term); RIGHT_BRACK  { Fun(func, l) }

assumption:
  | f = formula                       { Form(f) }
  | FRESH; v = VARIABLE               { Fresh(v) }
  | FRESH; v = VARIABLE; f = formula  { Fresh_Form(v, f) }

formula:
  | LEFT_BRACK; f = formula; RIGHT_BRACK  { f }
  | TRUE                                  { Const(true)   }
  | FALSE                                 { Const(false)  }
  | pred = NAME; LEFT_BRACK; l = separated_list(COMMA, term); RIGHT_BRACK 
                                          { Pred(pred, l) }
  | pred = NAME;                          { Pred(pred, [])}
  | NOT; f = formula                      { Not(f)        }
  | f1 = formula;  AND; f2 = formula      { And(f1,f2)    }
  | f1 = formula;  OR; f2 = formula       { Or(f1,f2)     }
  | f1 = formula;  IMPL; f2 = formula     { Impl(f1,f2)   }
  | f1 = formula;  IFF; f2 = formula      { Iff(f1,f2)    }
  | x = ALL; f = formula                  { All(x, f)     }
  | x = EXISTS; f = formula               { Exists(x, f)  }

proof_item:
  | LEFT_SQUARE_BRACK; a = assumption; COLON ;
    pil = proof;
    RIGHT_SQUARE_BRACK                             { Hypothesis(a, pil) }
  | f = formula                                    { Formula(f) }
  | PROVE_IT; CURLY_LEFT; f = formula; CURLY_RIGHT { Prove_it(f) }


proof:
  | l = separated_list(SEMI_COLON, proof_item) { Proof(l) }