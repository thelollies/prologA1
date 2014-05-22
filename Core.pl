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

giveSolution(P, Start, End, [Start|Steps]):- 
	(var(End) -> X=y ; X=f), % Sets X to indicate whether End was set
	giveSolution(P, Start, End, Steps, [Start]), 
	not(Start == End),
	(X == y -> setConnected([Start|Steps]); true). % If End was not set, remove results from unreachable nodes list.
giveSolution(_, B, B, [], _).
giveSolution(P, Start, End, [X|Steps], Visited):- 
	call(P, Start, X), 
	not(member(X, Visited)),
	giveSolution(P, X, End, Steps, [X|Visited]).

setConnected(Nodes):- setConnected(Nodes, Nodes).
setConnected([],_).
setConnected([Current|ToSave], Connected):- 
	getNodeReachables(Current, SavedReach), 
	subtract(Reachable, Connected, Result),
	nb_setval(Current, Result),
	setConnected(ToSave, Connected).

getNodeReachables(Node, Reachable):- 
	catch(nb_getval(Node, Reachable), 
        error(_,_Context),
        Reachable = []).

allCities(Result):- 
	findall(A,actionStreet(A,_),ListWith),
	sort(ListWith,Result).


node(Elem, SubNodes).
%artPoints(Nodes, ArtPoints):- 

/*makeTree(_, City, [], _, Tree):- Tree = node(City, []).
makeTree(P, City)
makeTree(P, City, Cities, Visited, Tree):- */


neighboursIn(P, [H|Possible] , City, Result):- 
	(call(P, City, H) -> Res = H; Res = []),
	neighboursIn(P, Possible, City, Rest),
	Result = [Res | Rest].  
neighboursIn(_, [], _, Result):- Result = [].