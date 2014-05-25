% Runs all the tests at once (the tests are the predicates whose comments have 
% a line that says TEST first, other predicates are helpers).
runAllTests:- 
	expectedResults, breadthFirstCorrectOrdering, noDuplicatesInResults, allPathsValid, performanceTest.

% TEST
% A series of tests which involve checking whether the three forms of 
% giveSolution give the correct results.
expectedResults:- 
	% Check that the number of street/path combinations FROM wellington
	% are the same for depth and breadth first search but not for iterative 
	% deepending because iterative deepending will only find one result
	aggregate_all(count, giveSolution(actionStreet, wellington, _, _), Count1),
	aggregate_all(count, giveSolutionBreadth(actionStreet, wellington, _, _), Count2),
	aggregate_all(count, giveSolutionIterative(actionStreet, wellington, _, 10, _), Count3),
	Count1 = Count2,
	Count3 \= Count2,
	% Check that the number of street/path combinations TO wellington
	% are the same for depth and breadth first search but not for iterative 
	% deepending because iterative deepending will only find one result
	aggregate_all(count, giveSolution(actionStreet, _, wellington, _), Count4),
	aggregate_all(count, giveSolutionBreadth(actionStreet, _, wellington, _), Count5),
	aggregate_all(count, giveSolutionIterative(actionStreet, _, wellington, 10, _), Count6),
	Count4 = Count5,
	Count6 \= Count5,
	% Check that each of the methods can find a result from auckland to hawkes_bay
	once(giveSolution(actionStreet, auckland, hawkes_bay, _)),
	once(giveSolutionBreadth(actionStreet, auckland, hawkes_bay, _)),
	once(giveSolutionIterative(actionStreet, auckland, hawkes_bay, 10, _)),
	% Check that paths are not found for disconnected cities.
	not(giveSolution(actionStreet, auckland, genoa, _)),
	not(giveSolutionBreadth(actionStreet, auckland, genoa, _)),
	not(giveSolutionIterative(actionStreet, auckland, genoa, 10, _)),
	% Check that every city has a path to itself containing only itself.
	once(giveSolution(actionStreet, X1, X1, _)),
	once(giveSolutionBreadth(actionStreet, X2, X2, _)),
	once(giveSolutionIterative(actionStreet, X3, X3, 1, _)),
	% Ensure that no path exists with no steps
	not(giveSolution(actionStreet, _, _, [])),
	not(giveSolutionBreadth(actionStreet, _, _, [])),
	not(giveSolutionIterative(actionStreet, _, _, 10, [])),
	% Check that a start/end is found for valid path
	once(giveSolution(actionStreet, _, _, [auckland, hamilton, taupo, hawkes_bay, wellington])),
	once(giveSolutionBreadth(actionStreet, _, _, [auckland, hamilton, taupo, hawkes_bay, wellington])),
	once(giveSolutionIterative(actionStreet, _, _, 10, [auckland, hamilton, taupo, hawkes_bay, wellington])),
	% Check that a start/end is NOT found for an INVALID path (cannot go hawkes_bay to genoa)
	not(giveSolution(actionStreet, _, _, [auckland, hamilton, taupo, hawkes_bay, genoa])),
	not(giveSolutionBreadth(actionStreet, _, _, [auckland, hamilton, taupo, hawkes_bay, genoa])),
	not(giveSolutionIterative(actionStreet, _, _, 10, [auckland, hamilton, taupo, hawkes_bay, genoa])),
	% Iterative deepening shouldn't get a result if the number of steps from the start
	% is more than the maximum depth
	not(giveSolutionIterative(actionStreet, auckland, wellington, 3, [auckland, hamilton, taupo, hawkes_bay, wellington])),
	once(giveSolutionIterative(actionStreet, auckland, wellington, 4, [auckland, hamilton, taupo, hawkes_bay, wellington])).

% TEST
% Checks whether the breadth first search is indeed acting in a breadth first fashion by
% checking that the results are ordered from the shortest to the longest (since searching
% breadth first means you get the shortest paths first).
breadthFirstCorrectOrdering:- 
	findall(Path, giveSolutionBreadth(actionStreet, wellington, _, Path), List), increasingLength(List).

% Determines whether a list of lists is ordered by list length ascending. 
increasingLength([]).
increasingLength([_]):- !.
increasingLength([First|[Second|Rest]]):-
	length(First, F),
	length(Second, S),
	F =< S,
	increasingLength([Second|Rest]).

% TEST
% NOTE: takes a long time to run
% Finds all possible paths in the New Zealand graph from wellington
% and checks there are no duplicates (does not find ALL paths as it takes
% multiple minutes to run this predicate with so many paths). This predicate
% has been tested and worked with all possible paths.
noDuplicatesInResults:- 
	findall(Path1, giveSolution(actionStreet, wellington, _, Path1), List1), noDup(List1),
	findall(Path2, giveSolutionBreadth(actionStreet, wellington, _, Path2), List2), noDup(List2).

% TEST
% NOTE: takes a long time to run
% Finds all possible paths graph and checks that each path starts at the specified start, 
% ends at the specified end and is made uf of a series of valid streets.
allPathsValid:-
	findall((Start1, End1, Path1), giveSolution(actionStreet, Start1, End1, Path1), List1), validPaths(List1),
	findall((Start2, End2, Path2), giveSolutionBreadth(actionStreet, Start2, End2, Path2), List2), validPaths(List2).
	
% Checks whether a list of paths is valid
validPaths([]).
validPaths([(Start, End, [Start|Rest])|Remainder]):- 
	last([Start|Rest], End),
	once(validPath([Start|Rest])),
	validPaths(Remainder).

% Checks whether a single path is valid
validPath([_]).
validPath([From|[To|Rest]]):- 
	actionStreet(From, To), validPath([To|Rest]).

% Determines whether there are duplicates in the given list
noDup(L) :-
    setof(X, member(X, L), Set), 
    length(Set, Len), 
    length(L, Len).

% TEST
% A sample run of the performance predicate.
performanceTest:- 
	performance(actionStreet, wellington, hawkes_bay, _, 10).