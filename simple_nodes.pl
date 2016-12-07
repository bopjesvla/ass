leaf(_).
node(_) :- fail.
node(X,Y,_) :- X,Y.

isBinaryTree(Tree) :- Tree.

nnodes(leaf(_), N) :- N = 1.
nnodes(node(X,Y), N) :- nnodes(X, A), nnodes(Y, B), N is A + B + 1.

makeBinary(0, Tree) :- Tree = leaf(0).
makeBinary(N, Tree) :- M is N - 1, makeBinary(M, T), Tree = node(T, T, N).
