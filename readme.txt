CORE:

I completed the core requirement by calling a checkIsthmus/4 predicate whenever
none of the searches originating from a given edge found the end. If checkIsthmus
found that the failing edge was also an isthmus then that edge was cached as one
not to revisit, but only when heading to the same end node in the same direction
(otherwise correct paths may be avoided).

The way I determined if an edge was an isthmus is by checking if the two nodes
either side of it were not connected when the edge was removed. This relies on
the fact that the predicate is always called on a valid edge since calling it on
two edges which are already not connected will lead to the edge between them
being marked as an edge (not that this matters since the algorithm will never
try to go between disconnected nodes anyway).

COMPLETION:

Breadth first and iterative deepending are better than depth first for finding the
shortest path because they always find the shortest path first. Iterative deepening
is better than breadth first because it does not suffer from the memory burden that 
a breadth first search does because in breadth first the list of remaining nodes
must be maintained which can grow very fast. Iterative deepening is a fusion of breadth
first and depth first as it repeatedly performs a depth first search to incrementally 
deeper depths until it reaches the maximum depth or finds a solution. It therefore
increases it's search by one level each time, like breadth first.