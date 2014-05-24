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
street(auckland, northland).

actionStreet(A,B):- street(A,B); street(B,A).

:-dynamic isthmus/3.

% A predicate describing paths between cities, search occurs depth first
giveSolution(P, Start, End, [Start|Steps]):- 
	giveSolution(P, Start, End, Steps, [Start]).
giveSolution(_, End, End, [], _).
giveSolution(P, Current, End, [Next|Steps], Visited):- 
	next(P, Current, End, Visited, Next),
	(giveSolution(P, Next, End, Steps, [Next|Visited]) *-> true;
	(checkIsthmus(End, Current, Next), false)).

% A predicate describing paths between cities, search occurs depth first
giveSolutionBreadth(P, Start, End, [Start|Steps]):- 
	giveSolutionBreadth(P, Start, End, Steps, [Start]).
giveSolutionBreadth(_, End, End, [], _).
giveSolutionBreadth(P, Current, End, [Next|Steps], Visited):- 
	next(P, Current, End, Visited, Next),
	(giveSolutionBreadth(P, Next, End, Steps, [Next|Visited]) *-> true;
	(checkIsthmus(End, Current, Next), false)).

% Finds the next possible node using a given transition function
next(P, Current, End, Visited, Next):- 
	call(P, Current, Next),
	not(member(Next, Visited)),
	not(isthmus(End, Current, Next)).

% Uncaches all streets to avoid
cleanUp:- retractall(isthmus(_,_,_)).

% Marks a street as not worth going down when searching for the 
% specifed End if it is an isthmus. Should only be called on
% streets that led to no results being found. 
checkIsthmus(End, From, To):- 
	isthmus(End, From, To); isIsthmus(From, To), assert(isthmus(End, From, To)).

% Determines if the street between two cities is an isthmus.
% Assumes there is a street between the provided cities.
isIsthmus(Node1, Node2):- not(notIsthmus(Node1, Node2, [Node1, Node2])).
notIsthmus(Current, Node2, Nodes):- 
	actionStreet(Current, Next), not(member(Next, Nodes)),
	(actionStreet(Next, Node2); notIsthmus(Next, Node2, [Next|Nodes])).