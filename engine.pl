% Provided street definitions
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
street(auckland, whangamata).
street(whangamata, whitianga).
street(whitianga, coromandel).
street(whangamata, hawkes_bay).
street(wellington, wairarapa).
street(wairarapa, hawkes_bay).
street(wellington, kapiti).
street(kapiti, otaki).
street(otaki, new_plymoth).
street(auckland, albany).
street(albany, orewa).
street(orewa, warkworth).
street(warkworth, whangarei).
street(whangarei, dargaville).
street(dargaville, kaikohe).
street(kaikohe, whangarei).
street(kaikohe, kerikeri).
street(kerikeri, kaitaia).
street(kaitaia, kaikohe).
street(hawkes_bay, danniverke).
street(danniverke, wairarapa).
street(hawkes_bay, hastings).
street(hastings, napier).
street(napier, hawkes_bay).

actionStreet(A,B):- street(A,B); street(B,A).

% isthmus(End, From, To) marks a street as one that shouldn't be gone down if
% you are searching for the node End
:-dynamic isthmus/3.

% predCalls(PredicateName, NumberOfCalls) is used to count how many times a 
% predicate has been called
:-dynamic predCalls/2.

% A predicate describing paths between cities, search occurs depth first
giveSolution(P, Start, End, [Start|Steps]):- 
	giveSolution(P, Start, End, Steps, [Start]), callPred(giveSolution), cleanUp.
giveSolution(_, End, End, [], _):- callPred(giveSolution).
giveSolution(P, Current, End, [Next|Steps], Visited):- 
	callPred(giveSolution),
	nextNoIsthmus(P, Current, End, Visited, Next),
	(giveSolution(P, Next, End, Steps, [Next|Visited]) *-> true;
	(checkIsthmus(P, End, Current, Next), false)).

% A predicate describing paths between cities, search occurs breadth first
giveSolutionBreadth(P, Start, End, Steps):- 
	giveSolutionBreadth_(P, [(Start, [Start])], End, Steps), callPred(giveSolutionBreadth).
giveSolutionBreadth_(_, [(End, Visited)|_], End, Steps):- reverse(Visited, Steps), callPred(giveSolutionBreadth).
giveSolutionBreadth_(P, [(Current, Visited)|Rest], End, Steps):-
	callPred(giveSolutionBreadth),
	findall((Next, [Next|Visited]), next(P, Current, Visited, Next), NewAdditions),
	append(Rest, NewAdditions, Nodes),
	giveSolutionBreadth_(P, Nodes, End, Steps).

% A predicate describing paths between cities, search is iteratively deepened
giveSolutionIterative(P, Start, End, MaxDepth, [Start|Steps]):- 
	iterateUpSolutions(P, Start, End, 1, MaxDepth, Steps).
giveSolutionIterative(_, End, End, _, [], _):- callPred(giveSolutionIterative).
giveSolutionIterative(P, Current, End, MaxDepth, [Next|Steps], Visited):- 
	callPred(giveSolutionIterative),
	MaxDepth > 0,
	next(P, Current, Visited, Next),
	giveSolutionIterative(P, Next, End, MaxDepth - 1, Steps, [Next|Visited]).

% A helper predicate that repeats giveSolutionIterative with increasing maximim
% depth until a result is found or the maximum depth is reached. A cut is used
% to prevent backtracking if any solution is found.
iterateUpSolutions(P, Start, End, Depth, MaxDepth, Steps):-
	Depth =< MaxDepth,
	callPred(giveSolutionIterative),
	(giveSolutionIterative(P, Start, End, Depth, Steps, [Start]), !;
		iterateUpSolutions(P, Start, End, Depth + 1, MaxDepth, Steps)).

% Finds the next possible node using a given transition function
% that has not been visited
next(P, Current, Visited, Next):- 
	call(P, Current, Next),
	not(member(Next, Visited)).

% Finds the next possible node using a given transition function
% that has not been visited yet. Also checks the street is not an 
% isthmus which doesn't have the End on the other side.
nextNoIsthmus(P, Current, End, Visited, Next):- 
	call(P, Current, Next),
	not(member(Next, Visited)),
	not(isthmus(End, Current, Next)).

% Un-caches all streets to avoid
cleanUp:- retractall(isthmus(_,_,_)).

% Marks a street as not worth going down when searching for the 
% specifed End if it is an isthmus. Should only be called on
% streets that led to no results being found. 
checkIsthmus(P, End, From, To):- 
	isthmus(End, From, To); isIsthmus(P, From, To), assert(isthmus(End, From, To)).

% Determines if the street between two nodes is an isthmus.
% Assumes there is a street between the two nodes.
isIsthmus(P, Node1, Node2):- not(notIsthmus(P, Node1, Node2, [Node1, Node2])).
notIsthmus(P, Current, Node2, Nodes):- 
	call(P, Current, Next), not(member(Next, Nodes)),
	(call(P, Next, Node2); notIsthmus(P, Next, Node2, [Next|Nodes])).

% Increments (or starts) the count for the predicate with the given Name 
callPred(Name):- 
	predCalls(Name, X), Y is X + 1, retract(predCalls(Name, X)), assert(predCalls(Name, Y)), !;
	assert(predCalls(Name, 1)).

% Gives performance statistics for the given three predicates.
% Performance statistics are the Time that each predicate takes
% as well as the number of predicate (and subpredicate) calls for
% each predicate.
performance(P, Start, End, Steps, MaxDepth):- 
	retractall(predCalls(_,_)), % Reset predicate call counts
	statistics(cputime, SN), 
	findall(_, call(giveSolution, P, Start, End, Steps),_), 
	statistics(cputime, EN), TNormal is round(1000000*(EN - SN)),
	statistics(cputime, SB), 
	writef('%w\n',[performance(P, Start, End, Steps, MaxDepth)]),
	findall(_, call(giveSolutionBreadth, P, Start, End, Steps),_), statistics(cputime, EB), 
	TBreadth is round(1000000*(EB - SB)),
	statistics(cputime, SI), 
	findall(_, call(giveSolutionIterative, P, Start, End, MaxDepth, _),_), statistics(cputime, EI), 
	TIterative is round(1000000*(EI - SI)),
	predCalls(giveSolution, CNormal), predCalls(giveSolutionBreadth, CBreadth), predCalls(giveSolutionIterative, CIterative),
	write('Performance Results\nTime (microseconds):\n'),
	writef('\tNormal: %w\n\tBreadth: %w\n\tIterative: %w\n',[TNormal, TBreadth, TIterative]),
	write('Predicate Calls:\n'),
	writef('\tNormal: %w\n\tBreadth: %w\n\tIterative: %w\n',[CNormal, CBreadth, CIterative]).
 
	