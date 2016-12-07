node(_,_). % leaf = node([], 0)

isBinaryTree(node([X, Y], _)) :- isBinaryTree(X), isBinaryTree(Y).
isBinaryTree(node([], _)).

nnodes(node([], _), N) :- N = 1.
nnodes(node([], _), N) :- N = 1.
nnodes(node([Head | Tail], Label), N) :- nnodes(Head, H), nnodes(node(Tail, Label), T), N is T + H.

% nnodes(node([node([node([],0), node([],0)], 0), node([],0)], 0), 5), nnodes(node([], 0), 1), nnodes(node([node([],0)],0), 2).
% isBinaryTree(node([], 0)), isBinaryTree(node([node([node([],0), node([],0)], 0), node([],0)], 0)), \+ isBinaryTree(node([node([],0)],0)).

makeBinary(0, Tree) :- Tree = node([],0).
makeBinary(N, Tree) :- M is N - 1, makeBinary(M, T), Tree = node([T, T], N).
