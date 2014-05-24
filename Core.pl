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

giveSolution(P, Start, End, Steps):- 
	giveSolution(P, Start, End, StepsBackwards, [Start]),
	reverse(StepsBackwards, Steps).
giveSolution(_, End, End, Visited, Visited).
giveSolution(P, Current, End, Steps, Visited):- 
	next(P, Current, End, Visited, Next), 
	(giveSolution(P, Next, End, Steps, [Next|Visited]) ->
	true ; (checkIsthmus(End, Current, Next), false)).

checkIsthmus(End, From, To):- 
	isthmus(End, From, To); isIsthmus(From, To), assert(isthmus(End, From, To)).

% Determines if the street between two cities is an isthmus.
% Assumes there is a street between the provided cities.
isIsthmus(From, To):- indirectlyConnected(Node1, Node2, [Node1, Node2]).
isIsthmus(Current, Node2, Nodes):- 
	actionStreet(Current, Next), not(member(Next, Nodes)),
	(actionStreet(Next, Node2); indirectlyConnected(Next, Node2, [Next|Nodes])).

next(P, Current, End, Visited, Next):- 
	call(P, Current, Next),
	writef('%w \n', [next(P, Current, End, Visited, Next)]),
	not(member(Next, Visited)),
	not(isthmus(End, Current, Next)).

/*allCities(Result):- 
	findall(A,actionStreet(A,_),ListWith),
	sort(ListWith,Result). % Remove duplicates*/