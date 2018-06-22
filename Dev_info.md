# Proof checker - informacja dla dewelopera
#### Wojtek Fica

### Struktura projektu
Najważniejszy fragment zadania jest napisany w plikach
- [rules.ml](rules.ml)
- [natural_deduction.ml](natural_deduction.ml)
- [proof_assistant.ml](proof_assistant.ml)

Zgodnie z idea, że najlepszą dokumentacją jest kod źródłowy, zainteresowanych odsyłam do źródeł, a poniżej opiszę strukturę projektu. Aby zdobyć dobre rozeznanie wystarczy przejrzeć następujące pliki.

### proof_type.ml
Plik zawiera definicje typów używanych w rozwiązaniu oraz kilka pomocniczych funkcji. Pomocnicze funkcje można pominąć w pierwszym czytaniu.
Formuły zapisujemy jak standardowe predykaty logiki pierwszego rzędu. Dowód jest listą składającą się z formuł udowodnionych przez użytkownika, hipotez lub formuł od udowodnienia przez program. 

### rules.ml
Plik implementuje reguły dedukcji naturalnej. W osobnych funkcjach zaimplementowane są reguły wprowadzania i eliminacji operatorów oraz kwantyfikatorów. 
Gdy pytamy się programu czy mając jakąś wiedzę L (listę formuł i hipotez, o których wiemy, że są prawdziwe) dana formuła F jest prawdziwa, to aplikujemy ww. reguły do elementów L i sprawdzamy, czy wynik zastosowania tej reguły jest równy F. 

### proof_assistant.ml
Moduł dostając jakąś wiedzę próbuje udowodnić formułę, której dowód może być niepełny. Tzn. sprawdza czy dana formuła jest prawdą, a jeśli nie, to sprawdza czy jest ona następnikiem jakiejś prawdziwej implikacji i rekurencyjnie sprawdza czy poprzednik danej implikacji jest prawdziwy. Głębokość rekursji będzie wynosić maksymalnie 3 wywołania. Jeśli udało się uzupełnić dowód, to proof_assistant zwraca najkrótszy dowód jaki udało mu się znaleźć. 

### natural_deduction.ml
Moduł jest odpowiedzialny za sprawdzanie poprawności dowodu. Na początek przyjmujemy, za nasz stan wiedzy aksjomaty oraz udowodnione wcześniej formuły. Następnie iterujemy się po dowodzie i każdego elementu dowodu, jeśli jest on:
- formułą, to sprawdzamy, czy tę formułę da się udowodnić z naszym obecnym stanem wiedzy,
- hipotezą, to dodajemy założenia hipotezy do naszej wiedzy i sprawdzamy, czy tę formułę da się udowodnić z naszym obecnym stanem wiedzy,
- formułą do udowodnienia przez program, to sprawdzamy, czy proof_assistant jest w stanie ją udowodnić.
Jeśli nie udało się potwierdzić poprawności kolejnego elementu dowodu, to przerywamy wykonanie i zwracamy informację o błędzie. Jeśli nie to dodajemy właśnie udowodniony fragment do naszej wiedzy i powtarzamy czynności dla kolejnych elementów dowodu.



