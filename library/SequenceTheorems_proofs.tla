----------------------- MODULE SequenceTheorems_proofs ----------------------
(***************************************************************************)
(* This module contains the proofs for theorems about sequences and the    *)
(* corresponding operations.                                               *)
(***************************************************************************)
EXTENDS Sequences, NaturalsInduction, Functions, TLAPS


(***************************************************************************)
(* Elementary properties about Seq(S)                                      *)
(***************************************************************************)

LEMMA SeqDef == \A S : Seq(S) = UNION {[1..n -> S] : n \in Nat}
OBVIOUS

THEOREM SeqMonotonic ==
  ASSUME NEW S, NEW T, NEW seq \in Seq(S),
         S \subseteq T
  PROVE  seq \in Seq(T)
OBVIOUS

THEOREM ElementOfSeq ==
   ASSUME NEW S, NEW seq \in Seq(S),
          NEW n \in 1..Len(seq)
   PROVE  seq[n] \in S
OBVIOUS
 
THEOREM EmptySeq ==
   ASSUME NEW S
   PROVE /\ << >> \in Seq(S)
         /\ Len(<< >>) = 0
         /\ \A seq \in Seq(S) : (seq # << >>) => (Len(seq) \in Nat \ {0})
OBVIOUS

THEOREM LenProperties == 
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE  /\ Len(seq) \in Nat
         /\ seq \in [1..Len(seq) -> S]
         /\ DOMAIN seq = 1 .. Len(seq) 
OBVIOUS

THEOREM IsASeq ==
  ASSUME NEW n \in Nat, NEW e(_), NEW S,
         \A i \in 1..n : e(i) \in S
  PROVE  [i \in 1..n |-> e(i)] \in Seq(S)
OBVIOUS

THEOREM ExceptSeq ==
  ASSUME NEW S, NEW seq \in Seq(S), NEW i \in 1 .. Len(seq), NEW e \in S
  PROVE  /\ [seq EXCEPT ![i] = e] \in Seq(S)
         /\ Len([seq EXCEPT ![i] = e]) = Len(seq)
         /\ \A j \in 1 .. Len(seq) : [seq EXCEPT ![i] = e][j] = IF j=i THEN e ELSE seq[j]
OBVIOUS

THEOREM SeqEqual ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S),
         Len(s) = Len(t), \A i \in 1 .. Len(s) : s[i] = t[i]
  PROVE  s = t
OBVIOUS

(**************************************************************************)
(* Properties of concatenation (\o)                                       *)
(**************************************************************************)

THEOREM ConcatProperties ==
  ASSUME NEW S, NEW s1 \in Seq(S), NEW s2 \in Seq(S)
  PROVE  /\ s1 \o s2 \in Seq(S)
         /\ Len(s1 \o s2) = Len(s1) + Len(s2)
         /\ \A i \in 1 .. Len(s1) + Len(s2) : (s1 \o s2)[i] =
                     IF i <= Len(s1) THEN s1[i] ELSE s2[i - Len(s1)]
OBVIOUS

THEOREM ConcatEmptySeq ==
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE  /\ seq \o << >> = seq
         /\ << >> \o seq = seq
OBVIOUS

THEOREM ConcatEqualIffEmpty ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S)
  PROVE  /\ s \o t = s <=> t = << >>
         /\ s \o t = t <=> s = << >>
         /\ s \o t = << >> <=> s = << >> /\ t = << >>
OBVIOUS \* BY Z3

THEOREM ConcatAssociative ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S), NEW u \in Seq(S)
  PROVE  (s \o t) \o u = s \o (t \o u)
BY Z3
(*
<1>. DEFINE lhs == (s \o t) \o u
            rhs == s \o (t \o u)
<1>. lhs \in Seq(S) /\ rhs \in Seq(S)  OBVIOUS
<1>1. Len(lhs) = Len(rhs)  OBVIOUS
<1>2. \A i \in 1 .. Len(lhs) : lhs[i] = rhs[i]  OBVIOUS
<1>. QED  BY <1>1, <1>2, SeqEqual, Zenon
*)

THEOREM ConcatSimplifications ==
  ASSUME NEW S
  PROVE  /\ \A s,t \in Seq(S) : s \o t = s <=> t = <<>>
         /\ \A s,t \in Seq(S) : s \o t = t <=> s = <<>>
         /\ \A s,t \in Seq(S) : s \o t = <<>> <=> s = <<>> /\ t = <<>>
         /\ \A s,t,v \in Seq(S) : s \o t = s \o v <=> t = v
         /\ \A s,t,v \in Seq(S) : s \o v = t \o v <=> s = t
<1>1. /\ \A s,t \in Seq(S) : s \o t = s <=> t = <<>>
      /\ \A s,t \in Seq(S) : s \o t = t <=> s = <<>>
      /\ \A s,t \in Seq(S) : s \o t = <<>> <=> s = <<>> /\ t = <<>>
  BY Z3  \*   BY ConcatEqualIffEmpty, Isa
<1>2. \A s,t,v \in Seq(S) : s \o t = s \o v <=> t = v
  BY Z3
<1>3. \A s,t,v \in Seq(S) : s \o v = t \o v <=> s = t
  BY Z3
<1>. QED  BY <1>1, <1>2, <1>3, Zenon

(***************************************************************************)
(*                     SubSeq, Head and Tail                               *)
(***************************************************************************)

THEOREM SubSeqProperties ==
  ASSUME NEW S, NEW s, NEW m \in Int, NEW n \in Int,
         \A i \in m .. n : s[i] \in S
   PROVE /\ SubSeq(s,m,n) \in Seq(S)
         /\ Len(SubSeq(s,m,n)) = IF m<=n THEN n-m+1 ELSE 0
         /\ \A i \in 1 .. n-m+1 : SubSeq(s,m,n)[i] = s[m+i-1]
OBVIOUS

THEOREM SubSeqEmpty ==
  ASSUME NEW s, NEW m \in Int, NEW n \in Int, n < m
  PROVE  SubSeq(s,m,n) = << >>
OBVIOUS

THEOREM HeadTailProperties ==
   ASSUME NEW S,
          NEW s \in Seq(S), s # << >>
   PROVE  /\ Head(s) \in S
          /\ Tail(s) \in Seq(S)
          /\ Len(Tail(s)) = Len(s)-1
          /\ \A i \in 1 .. Len(Tail(s)) : Tail(s)[i] = s[i+1]
OBVIOUS

THEOREM TailIsSubSeq ==
  ASSUME NEW S,
         NEW s \in Seq(S), s # << >>
  PROVE  Tail(s) = SubSeq(s, 2, Len(s))
OBVIOUS

THEOREM SubSeqRestrict ==
  ASSUME NEW S, NEW seq \in Seq(S), NEW n \in 0 .. Len(seq)
  PROVE  SubSeq(seq, 1, n) = Restrict(seq, 1 .. n)
BY DEF Restrict

THEOREM HeadTailOfSubSeq ==
  ASSUME NEW S, NEW seq \in Seq(S),
         NEW m \in 1 .. Len(seq), NEW n \in m .. Len(seq)
  PROVE  /\ Head(SubSeq(seq,m,n)) = seq[m]
         /\ Tail(SubSeq(seq,m,n)) = SubSeq(seq, m+1, n)
OBVIOUS

THEOREM SubSeqRecursiveFirst ==
  ASSUME NEW S, NEW seq \in Seq(S),
         NEW m \in 1 .. Len(seq), NEW n \in m .. Len(seq)
  PROVE  SubSeq(seq, m, n) = << seq[m] >> \o SubSeq(seq, m+1, n)
OBVIOUS

THEOREM SubSeqRecursiveSecond ==
  ASSUME NEW S, NEW seq \in Seq(S),
         NEW m \in 1 .. Len(seq), NEW n \in m .. Len(seq)
  PROVE  SubSeq(seq, m, n) = SubSeq(seq, m, n-1) \o << seq[n] >>
OBVIOUS

THEOREM SubSeqFull ==
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE  SubSeq(seq, 1, Len(seq)) = seq
OBVIOUS

(***************************************************************************)
(* Subsequences of subsequences.                                           *)
(***************************************************************************)
THEOREM SubSeqOfSubSeq ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S),
         NEW i \in 1 .. Len(s), NEW j \in 1 .. Len(s),
         NEW m \in 1 .. j-i+1, NEW n \in 1 .. j-i+1
  PROVE  SubSeq(SubSeq(s,i,j),m,n) = SubSeq(s, i+m-1, i+n-1)
OBVIOUS

(*****************************************************************************)
(* Adjacent subsequences can be concatenated to obtain a longer subsequence. *)
(*****************************************************************************)
THEOREM ConcatAdjacentSubSeq ==
  ASSUME NEW S, NEW seq \in Seq(S), 
         NEW m \in 1 .. Len(seq)+1, 
         NEW k \in m-1 .. Len(seq), 
         NEW n \in k .. Len(seq)
  PROVE  SubSeq(seq, m, k) \o SubSeq(seq, k+1, n) = SubSeq(seq, m, n)
OBVIOUS

(***************************************************************************)
(* Special cases of subsequences of concatenations.                        *)
(***************************************************************************)
THEOREM SubSeqOfConcat1 ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S),
         NEW m \in 1 .. Len(s), NEW n \in 1 .. Len(s)
  PROVE  SubSeq(s \o t, m, n) = SubSeq(s, m, n)
OBVIOUS

THEOREM SubSeqOfConcat2 ==
  ASSUME NEW S, NEW s \in Seq(S), NEW t \in Seq(S),
         NEW m \in Len(s)+1 .. Len(s)+Len(t), NEW n \in Len(s)+1 .. Len(s)+Len(t)
  PROVE  SubSeq(s \o t, m, n) = SubSeq(t, m - Len(s), n - Len(s))
OBVIOUS

(***************************************************************************)
(* Theorems about Append                                                   *)
(***************************************************************************)

THEOREM AppendProperties ==
  ASSUME NEW S, NEW seq \in Seq(S), NEW elt \in S
  PROVE  /\ Append(seq, elt) \in Seq(S)
         /\ Append(seq, elt) # << >>
         /\ Len(Append(seq, elt)) = Len(seq)+1
         /\ \A i \in 1.. Len(seq) : Append(seq, elt)[i] = seq[i]
         /\ Append(seq, elt)[Len(seq)+1] = elt
OBVIOUS

THEOREM AppendIsConcat ==
  ASSUME NEW S, NEW seq \in Seq(S), NEW elt \in S
  PROVE  Append(seq, elt) = seq \o <<elt>>
OBVIOUS

THEOREM HeadTailAppend ==
  ASSUME NEW S, NEW seq \in Seq(S), NEW elt
  PROVE  /\ Head(Append(seq, elt)) = IF seq = <<>> THEN elt ELSE Head(seq)
         /\ Tail(Append(seq, elt)) = IF seq = <<>> THEN <<>> ELSE Append(Tail(seq), elt)
OBVIOUS

THEOREM AppendInjective ==
  ASSUME NEW S, NEW e \in S, NEW s \in Seq(S), NEW f \in S, NEW t \in Seq(S)
  PROVE  Append(s,e) = Append(t,f) <=> s = t /\ e = f
OBVIOUS  \* BY Z3

THEOREM SequenceEmptyOrAppend == 
  ASSUME NEW S, NEW seq \in Seq(S), seq # << >>
  PROVE \E s \in Seq(S), elt \in S : seq = Append(s, elt)
<1>. DEFINE front == [i \in 1 .. Len(seq)-1 |-> seq[i]]
            last == seq[Len(seq)]
<1>. /\ front \in Seq(S)
     /\ last \in S
     /\ seq = Append(front, last)
  OBVIOUS
<1>. QED  OBVIOUS

(***************************************************************************)
(* Inductive reasoning for sequences                                       *)
(***************************************************************************)

THEOREM SequencesInductionAppend ==
  ASSUME NEW P(_), NEW S, 
         P(<< >>),
         \A s \in Seq(S), e \in S : P(s) => P(Append(s,e))
  PROVE  \A seq \in Seq(S) : P(seq)
<1>. DEFINE Q(n) == \A seq \in Seq(S) : Len(seq) = n => P(seq)
<1>. SUFFICES \A k \in Nat : Q(k)
  OBVIOUS
<1>1. Q(0)
  OBVIOUS
<1>2. ASSUME NEW n \in Nat, Q(n)
      PROVE  Q(n+1)
  <2>. SUFFICES ASSUME NEW s \in Seq(S), Len(s) = n+1
                PROVE P(s)
    OBVIOUS
  <2>. QED  BY SequenceEmptyOrAppend, Z3
<1>3. QED  BY <1>1, <1>2, NatInduction, Isa

THEOREM SequencesInductionTail ==
  ASSUME NEW S,  NEW P(_),
         P(<< >>), 
         \A s \in Seq(S) : (s # << >>) /\ P(Tail(s)) => P(s)
  PROVE  \A s \in Seq(S) : P(s)
<1>. DEFINE Q(n) == \A s \in Seq(S) : Len(s) = n => P(s)
<1>. SUFFICES \A k \in Nat : Q(k)
  OBVIOUS
<1>1. Q(0)
  OBVIOUS
<1>2. ASSUME NEW n \in Nat,  Q(n) 
      PROVE  Q(n+1)
  <2>. SUFFICES ASSUME NEW s \in Seq(S), Len(s) = n+1
                PROVE  P(s)
    OBVIOUS
  <2>1. /\ Tail(s) \in Seq(S)
        /\ Len(Tail(s)) = n
    OBVIOUS
  <2>. QED  BY <2>1, <1>2, Zenon
<1>3. QED  BY <1>1, <1>2, NatInduction, Isa


(***************************************************************************)
(*                          RANGE OF SEQUENCE                              *)
(***************************************************************************)

THEOREM RangeOfSeq == 
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE  Range(seq) \in SUBSET S
BY DEF Range

THEOREM RangeEquality == 
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE Range(seq) = { seq[i] : i \in 1 .. Len(seq) }
BY DEF Range

THEOREM SeqOfRange ==
  ASSUME NEW S, NEW seq \in Seq(S)
  PROVE  seq \in Seq(Range(seq))
BY DEF Range

(* The range of the concatenation of two sequences is the union of the ranges *)
THEOREM RangeConcatenation == 
  ASSUME NEW S, NEW s1 \in Seq(S), NEW s2 \in Seq(S)
  PROVE  Range(s1 \o s2) = Range(s1) \cup Range(s2)
<1>1. Range(s1) \subseteq Range(s1 \o s2)
  BY DEF Range
<1>2. Range(s2) \subseteq Range(s1 \o s2)
  <2>1. SUFFICES ASSUME NEW i \in 1 .. Len(s2)
                 PROVE  s2[i] \in Range(s1 \o s2)
    BY RangeEquality
  <2>2. /\ Len(s1)+i \in 1 .. Len(s1 \o s2)
        /\ (s1 \o s2)[Len(s1)+i] = s2[i]
    OBVIOUS
  <2>. QED  BY <2>2 DEF Range
<1>3. Range(s1 \o s2) \subseteq Range(s1) \cup Range(s2)
  BY DEF Range
<1>. QED  BY <1>1, <1>2, <1>3

=============================================================================