# The Hitting Tree Algorithm

Bob de Ruiter
s4344952
Representation and Interaction

## Task 1

a. To generate a conflict set using tp:

```prolog
root@bb-als7:~/prolog/ass# swipl
Welcome to SWI-Prolog (Multi-threaded, 64 bits, Version 7.2.3)
Copyright (c) 1990-2015 University of Amsterdam, VU Amsterdam
SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software,
and you are welcome to redistribute it under certain conditions.
Please visit http://www.swi-prolog.org for details.

For help, use ?- help(Topic). or ?- apropos(Word).

?- [diagnosis,tp].
Warning: /root/prolog/ass/tp.pl:128:
Singleton variable in branch: C
Singleton variable in branch: D
Warning: /root/prolog/ass/tp.pl:128:
Singleton variable in branch: C
Singleton variable in branch: D
true.

?- fulladder(SD, COMP, OBS), tp(SD, COMP, OBS, [], ConflictSet).
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), all _G91: (xor(_G91), ~ab(_G91)=> (out(_G91)<=>in1(...), ~ ...;~ ..., in2(...))), and(a1), and(a2), xor(x1), xor(x2), or(r1), (... <=> ...)|...],
COMP = [a1, a2, x1, x2, r1],
OBS = [in1(fa), ~in2(fa), carryin(fa), out(fa), ~carryout(fa)],
ConflictSet = [a1, x1, a2, r1, x2].
```

b. For each problem, COMP is a conflict set. Examples of other conflict sets:

Problem 1: {a1}, {a2}
Fulladder: {x1, a2, r1}

c. The proof that a1 is a conflict set in problem 1:

```prolog
SD ∪ {¬out(o1)} ∪ {¬Ab(a1)} = ⊥
SD ∪ OBS ∪ {¬Ab(c) | c ∈ COMP} = ⊥
SD ∪ OBS ∪ {¬Ab(c) | c ∈ CS} = ⊥
```

## Task 2

I chose to use Prolog's built-in search [1], where branches are represented by choice points and leafs are represented by unification. Since the tree isn't an explicit data structure, a predicate like `isHittingSetTree/1` is not applicable.

## Task 3

At this point, I slightly altered tp/1 to accept the set of normal components instead of the hitting set, since I found it easier to reason about:

```prolog
- tp(D, COMP, OBS, HS, CS) :-
+ tp(SD, COMP, OBS, NormComp, CS) :-
```

`set_minus_one/3` unifies a list, an element from that list, and that list without that element:

```prolog
set_minus_one([Removed | Y], Y, Removed).
set_minus_one([X | Y], [X | YminusOne], Removed) :- set_minus_one(Y, YminusOne, Removed).
```

```prolog
?- set_minus_one([a,b,c,d,e], X, Y).
X = [b, c, d, e],
Y = a ;
X = [a, c, d, e],
Y = b ;
X = [a, b, d, e],
Y = c ;
X = [a, b, c, e],
Y = d ;
X = [a, b, c, d],
Y = e ;
false.

?- member(Y, [a,b,qwerty]), set_minus_one([a,b,c,d,e], X, Y).
Y = a,
X = [b, c, d, e] ;
Y = b,
X = [a, c, d, e] ;
false.
```

Which is used here to remove elements from the set of normal components:

```prolog
maximal_norm_comp_set(SD, COMP, OBS, NormComps, MaximalNormComps) :- % node condition
  tp(SD, COMP, OBS, NormComps, CS), !,
  member(ToRemove, CS), % choice point
  set_minus_one(NormComps, NewNormComps, ToRemove),
  maximal_norm_comp_set(SD, COMP, OBS, NewNormComps, MaximalNormComps).

maximal_norm_comp_set(_, _, _, NormComps, NormComps). % leaf condition
```

In which

- the cut (`!/0`) makes sure that if the theorem prover finds a new conflict set, the node cannot be turned into leaf regardless of the failure of `member/2` or `set_minus_one/3`.
- `member/2` non-deterministically picks any element from CS
- `set_minus_one/3` removes this element from the set of normal components
- `maximal_norm_comp_set/5` is called with this slightly smaller set of normal components

However, if enough components have been assumed to be abnormal and the theorem prover does not find a conflict set, the set of the remaining normal components is instead unified with the result, which is propegated up in the node conditions.

```prolog
?- problem3(SD, COMP, OBS), maximal_norm_comp_set(SD, COMP, OBS, COMP, Res).
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [o1] ;
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [a2] ;
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [a1, a2] ;
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [o1] ;
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [a1] ;
false.
```

Two problems: the results should be collected in an array, and they should be sets of normal components, instead of sets of abnormal components. The set of abnormal components can be obtained by substracting the set of normal components from the set of all components, and the results can be collected using `findall/3`.

```prolog
minimal_hitting_sets(SD, COMP, OBS, MinimalHittingSets) :-
     findall(HittingSet, (
                 maximal_norm_comp_set(SD, COMP, OBS, COMP, MaxCompSet),
                 subtract(COMP, MaxCompSet, HittingSet)
             ), HittingSets).
```

```prolog
?- problem3(SD, COMP, OBS), minimal_hitting_sets(SD, COMP, OBS, Res).
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), and(a1), and(a2), or(o1), (out(a1)<=>in1(o1)), (out(a2)<=>in2(o1))],
COMP = [a1, a2, o1],
OBS = [in1(a1), in2(a1), in1(a2), in2(a2), ~out(o1)],
Res = [[a1, a2], [a1, o1], [o1], [a1, a2], [a2, o1]].
```

All that's left is to make the results subset minimal:

```prolog
has_subset(Sets, Set) :- member(Sub, Sets), subset(Sub, Set), \+ Sub = Set.

minimal_hitting_sets(SD, COMP, OBS, MinimalHittingSets) :-
  findall(...),
  list_to_set(HittingSets, UniqueHittingSets),
  exclude(has_subset(UniqueHittingSets), UniqueHittingSets, MinimalHittingSets).
```

This excludes all hitting sets that have another subset in the set of hitting sets:

```prolog
?- fulladder(SD, COMP, OBS), minimal_hitting_sets(SD, COMP, OBS, Res).
SD = [all _G33: (and(_G33), ~ab(_G33)=> (in1(_G33), in2(_G33)<=>out(_G33))), all _G62: (or(_G62), ~ab(_G62)=> (in1(_G62);in2(_G62)<=>out(_G62))), all _G91: (xor(_G91), ~ab(_G91)=> (out(_G91)<=>in1(...), ~ ...;~ ..., in2(...))), and(a1), and(a2), xor(x1), xor(x2), or(r1), (... <=> ...)|...],
COMP = [a1, a2, x1, x2, r1],
OBS = [in1(fa), ~in2(fa), carryin(fa), out(fa), ~carryout(fa)],
Res = [[x1], [a2, x2], [x2, r1]].
```

## Reflection

My implementation might be faster if I used the original implementation of `tp/1` and added to the hitting set instead of removing from the set of normal components, but when I gave that a quick shot my code stopped working.

Other than that, since the data structure is implicit, the most natural way to change the search strategy would be to write a meta-interpreter. The advantage of meta-interpreters is that they might be applied to multiple problems (e.g. pruning duplicate nodes can be applied to multiple problems), the disadvantage is that they require extensive knowledge of meta-programming in Prolog, which I don't have.

As for the complexity, since the entire search tree is traversed the time complexity is O(|V| + |E|), and the space complexity is O(|V|).
