street(genoa,turin).
street(genoa,busalla).
street(milan,turin).
street(milan,rome).
street(milan,genoa).
street(genoa,rome).
street(rome,napoli).

% My added street
street(wellington, hawkes_bay).
street(wellington, new_plymoth).
street(hawkes_bay, auckland).
street(hawkes_bay, new_plymoth).
street(new_plymoth, auckland).
street(hawkes_bay, taupo).
street(taupo, hamilton).
street(taupo, new_plymoth).
street(hamilton, auckland).

actionStreet(A,B):- street(A,B); street(B,A).

% Capture the case where not arguments are given to actionStreet
giveSolution(actionStreet, Start, End, Steps):- actionStreet(Start,X), giveSolution(actionStreet(Start, X), Start, End, Steps, [Start|[X]]).

% Base case
giveSolution(actionStreet(A,B), _, B, Steps, _):- actionStreet(A,B), Steps=[street(A,B)].

% Continue searching
giveSolution(actionStreet(A,B), Start, End, [street(A,B)|Steps], Visited):- 
	actionStreet(B,X), 
	not(member(X, Visited)), 
	giveSolution(actionStreet(B,X), Start, End, Steps, [X|Visited]).