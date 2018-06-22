# Proof checker
#### Wojtek Fica

Proof checker implementation in OCaml. It reads a proof line by line and checks if a current statement can be deduced from the previous ones. It supports first order logic and axioms (statemnents that are considered true). See example inputs in [tests](/tests).  Details are available in Polish [here](proof_checker.pdf).

### Exemplary proof
```
goal modusPonens: P /\ (P => Q) => Q
proof
    [   P /\ (P => Q) :
        P;
        P => Q;
        Q ];
    P /\ (P => Q) => Q
end.
``` 


### Compilation
- compilation: ```make proof_checker```
- cleaning: ```make clean```

### Run
```./proof_checker.native in out```

### Syntax
Specified in proof_checker.pdf (in Polish), but:
- variable name must match: ```(['B'-'D'] | ['F' - 'Z']) ['a'-'z' 'A'-'Z' '0'-'9' '_']*```
- target name must match: ```['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*```
- first order logic: ```A x formula```, ```E x formula```
- gaps in a proof: ```prove_it { formula }```

You can find example tests in ```/tests``` folder - [here](/tests).

### Tests
| Test      | Correct or incorrect proofs | Extension         |
| --------- | --------------------------- | ----------------- |
| tests/in0 | correct                     | none              |
| tests/in1 | incorrect                   | none              |
| tests/in2 | correct                     | axioms            |
| tests/in3 | incorrect                   | first order logic |
| tests/in4 | correct                     | first order logic |
| tests/in5 | correct                     | gaps in a proof   |
| tests/in6 | incorrect                   | gaps in a proof   |


---

### Specyfikacja
Implementacja podstawowej wersji zadania z dodatkami:
- Aksjomaty
- Logika klasyczna (prawo eliminacji podwójnej negacji)
- Logika pierwszego rzędu
- Program próbuje uzupełnić luki w dowodzie


### Struktura projektu
Najważniejszy fragment zadania jest napisany w plikach
- [rules.ml](rules.ml)
- [natural_deduction.ml](natural_deduction.ml)
- [proof_assistant.ml](proof_assistant.ml)

### Kompilacja
- kompilacja: ```make proof_checker```
- sprzątanie: ```make clean```

### Uruchomienie
```./proof_checker.native in out```

### Składnia
Składnia jak w specyfikacji zadania, ale:
- nazwa zmiennej dopasować się do następującego wyrażenia regularnego: ```(['B'-'D'] | ['F' - 'Z']) ['a'-'z' 'A'-'Z' '0'-'9' '_']*```
- nazwa celu dopasować się do następującego wyrażenia regularnego: ```['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*```
- logika I rzędu: ```A x formula```, ```E x formula```
- luki w dowodzie: ```prove_it { formula }```
- w folderze ```tests/``` dostarczone są testy z przykładowymi dowodami

### Testy
| Test      | Opis      | Rozszerzenie          |
| --------- | --------- | --------------------- |
| tests/in0 | correct   | wersja bez rozszerzeń |
| tests/in1 | incorrect | wersja bez rozszerzeń |
| tests/in2 | correct   | aksjomaty             |
| tests/in3 | incorrect | logika I rzędu        |
| tests/in4 | correct   | logika I rzędu        |
| tests/in5 | correct   | ```prove_it {}```     |
| tests/in6 | incorrect | ```prove_it {}```     |

