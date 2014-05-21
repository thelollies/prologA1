street(genoa,turin).
street(genoa,busalla).
street(milan,turin).
street(milan,rome).
street(milan,genoa).
street(genoa,rome).
street(rome,napoli).

% My added streets
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

% Fix this first part of giveSolution. Shouldn't allow going from same start finish
giveSolution(P, Start, End, Steps):- giveSolution(P, X, End, Steps, [Start]).
giveSolution(_, B, B, Steps, _):- Steps=[].
giveSolution(P, Start, End, [street(A,B)|Steps], Visited):- 
	call(P, Start, X), 
	not(member(X, Visited)), 
	giveSolution(P, X, End, Steps, [X|Visited]).