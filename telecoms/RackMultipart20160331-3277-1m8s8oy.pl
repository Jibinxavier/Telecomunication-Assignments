lc(X,KB) :- cn(C,KB), member(X,C).
cn(C,KB) :- cn([],C,KB).
cn(TempC,C,KB) :- member([H|B],KB),
all(B,TempC),
nonmember(H,TempC),
cn([H|TempC],C,KB).
cn(C,C,_).
all([],_).
all([H|T],L) :- member(H,L), all(T,L).
nonmember(_,[]).
nonmember(X,[H|T]) :- X\=H, nonmember(X,T).

append_to([],KB,KB).
append_to([H|T],KB,Result):- append(KB,[[H]],NewKB),append_to(T,NewKB,Result).

lcRule([H|T],KB):-append_to(T,KB,Result),lc(H,Result),!.