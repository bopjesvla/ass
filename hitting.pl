set_minus_one([Removed | Y], Y, Removed).
set_minus_one([X | Y], [X | YminusOne], Removed) :- set_minus_one(Y, YminusOne, Removed).

has_subset(Sets, Set) :- member(Sub, Sets), subset(Sub, Set), \+ Sub = Set.

minimal_hitting_sets(SD, COMP, OBS, MinimalHittingSets) :-
    findall(HittingSet, (
		maximal_norm_comp_set(SD, COMP, OBS, COMP, MaxCompSet),
		subtract(COMP, MaxCompSet, HittingSet)
	    ), HittingSets),
    % filter out hitting sets that have a subset in the set of hitting sets
    list_to_set(HittingSets, UniqueHittingSets),
    exclude(has_subset(UniqueHittingSets), UniqueHittingSets, MinimalHittingSets).

maximal_norm_comp_set(SD, COMP, OBS, NormComps, MaximalNormComps) :-
    % NOTE: I slightly altered tp to accept the normal components instead of the hitting set since I found it easier to reason about; performance should be the same
    tp(SD, COMP, OBS, NormComps, CS), !,
    member(ToRemove, CS),
    set_minus_one(NormComps, NewNormComps, ToRemove),
    maximal_norm_comp_set(SD, COMP, OBS, NewNormComps, MaximalNormComps).

maximal_norm_comp_set(_, _, _, NormComps, NormComps).
