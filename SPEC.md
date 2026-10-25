# restrict-lang specification (draft)

Status: draft before milestone M0. `restrict-lang` is a working name.

Fill each section. The quoted line under each heading says what to write
there. Delete the quoted line when the section is complete.

## 1. Purpose

> Write here: what one program describes, what the compiler checks, and what
> it writes. Name the host and the target. Say that the core types and core
> operations are only those of `design/DESIGN.md`.

restrict-lang is a language for <the domain>. Its type formers are F1 to F19 of
`formers/FORMERS.md`. Its core data types and core operations are only the
types and operations of `design/DESIGN.md` (the design).

## 2. Programs

> Write here: the form of a program and the refusal list. Copy the host
> forms from `formers/tcc-evm-contract.md`. Add each fixed first definition that the
> domain needs (for example a size parameter).

A program is a sequence of definitions:

```
def NAME : TYPE := TERM
```

The compiler refuses these host forms in a program: <the list from
`formers/tcc-evm-contract.md`>. It also refuses a definition that uses a core name or
a prelude name. Thus a program cannot add a data type, an unproved fact or
general recursion. Recursion comes only from `fold` and `unfold` (F6, F7).
The compiler writes the target; a program cannot.

Only `domain/domain.lang` declares a family; a `family` in a program gives
`REFUSE_DATA`. A family with a type parameter is a type constructor, so it
must be a cell signature (rule R1, S3): only type parameters, no `and`
block, each type parameter the one field of exactly one generator
constructor, and each other point field closed base data (independent of
the parameters and earlier fields), the family at its own parameters or
a path in it. Universe aliases in headers are normalized before this
shape check. Higher-kinded parameters and type indices are refused: type
arguments must be uniform universe parameters of a cell signature.
Else the checker gives `REFUSE_CELL`.
The cons list `List` (with `nil`, `cons` and `unfold`) is the kit host ABI:
a guest program that names one gives `REFUSE_CELL` and uses `FreeMon` of
`domain/domain.lang` in its place.
The dual of a cell monad is the cofree comonad of a cocell signature (S4,
O28). Only `domain/domain.lang` declares one: `cofamily D (A : Type n) :=
c (o : A) (f : D A) (g : E -> D A)`. A `cofamily` in a program gives
`REFUSE_DATA`. The shape: one type parameter, no index, no `and` block,
one clause with no result and no boundary, exactly one observation field
of the type `A`, and each other field a cofield `D A` or a labelled
cofield `E -> D A` with `E` closed base data in a universe at most `n`.
Else the checker gives `REFUSE_CELL`.
Closed labels are checked after normalization; erased references to the
parameter or earlier fields do not make a label dependent. The checked
closed label core is retained for `D.g.E`.
The checker elaborates the
cofamily to text (choice (ii)) and checks each generated declaration:
the positions `family D.pos := D.here | D.f (D.f.rest : D.pos) |
D.g (D.g.label : D.g.E) (D.g.rest : D.pos)` (with `def D.g.E := E`),
`def D := fun A => D.pos -> A`, the destructors `o : D A -> A` (the
position `D.here`), `f : D A -> D A` and `g : D A -> E -> D A`, the walk
`D.walk` (a fold over the positions that applies the steps from the
seed), the corecursor `c : (A S : Type n) -> (S -> A) -> steps -> S ->
D A` and the bisimulation principle `DBisim`. The steps and the
hypotheses of `DBisim` follow the field order. The generated names are
core names (rule R4): a definition that holds one gives `REFUSE_NAME`.
The head of a corecursor value is the observation of the seed, and its
tail is the corecursor at the next seed, by conversion. A state field of
a cofamily type is a function type, so it gives `REFUSE_STATE`.
The modifiers `sealed family` and `law def` are domain only (rule O7,
S5). A program that uses one gives `REFUSE_DATA`. The domain declares
`sealed family Enc (A : Type 0) := encEta (encOf : A)`, the identity cell
monad with a sealed eliminator, with `encBind`, `encMap` and `encOp2`.
It also declares two law defs: `decrypt : (A : Type 0) -> Enc A -> A` (the
counit) and `observe : (A : Type 0) -> Enc A -> Trunc1 A` (decrypt under
`Trunc1`). The law-only roots are a law def, an `elim` or a `fold` of a
sealed family, and a projection of a field of a sealed family's
constructor. A guest definition that uses a root or a law-only guest
definition is law-only too. The checker walks the checked declared type
before normalization, its quoted normal form, and the body of each guest
definition. Explicit binder annotations are retained for this walk, even
when their variables are unused. The walk does not enter an application of
the type former `Trunc1` (the constructor `trunc1` has no exemption). A
law-only guest definition must have a law type: after its Pi binders,
the codomain is a `Path` or a `Trunc1`. Else the checker gives
`REFUSE_LAW`. Kit mode records the law-only flag and does not refuse. A
state field of type `Enc A` gives `REFUSE_STATE`. The host model is
exponential ElGamal over BN254 G1 (`src/front/elgamal.c`, not guest
visible). The domain also declares `family Quorum := quorum (quorumT :
Size) (quorumN : Size)` (S6), the public part of a threshold opening (t
of n). Quorum is not sealed and has no parameter. The law def `open : (A
: Type 0) -> Quorum -> Enc A -> A` is `decrypt` for each quorum. A guest
use of `open` outside a law type gives `REFUSE_LAW`, as `decrypt` does. A
state field of type `Quorum` gives `REFUSE_STATE`. The shares, the partial
decryptions and their DLEQ proofs are host data (`src/front/threshold.c`).
The dealer requires fresh private seed entropy for its polynomial
coefficients; public coefficients expose sk from one share.
The chain checks one proof and the opening with `ecMul`, `ecAdd` and
`hash` (`examples/threshold.lang`).
The domain declares `def ZKProof : Type 0 -> Type 0 := fun W => Trunc1
W` (S7): a proof of W is the truncation of W, and zero knowledge is the
squash cell. ZKProof is a def, not a family. The O7 walk does not enter
an application of `ZKProof`, as it does not enter one of `Trunc1`: the
checked declared type is walked before normalization, where `ZKProof W`
is still an application of the def. The domain also declares `sealed
family Transcript (W : Type 0) := transcript (transcriptOf : W)`. In the
ideal model a transcript holds its witness, as an `Enc` holds its
plaintext. The law def `verified : (W : Type 0) -> Transcript W ->
ZKProof W` truncates the witness. A guest use of `verified` outside a law
type gives `REFUSE_LAW`, as `decrypt` does. A state field of type
`Transcript W` gives `REFUSE_STATE`. A failed check is a host refusal or
a chain revert, so the codomain is not an `Option`. The real proofs are
host data (`src/front/sigma.c`): a proof of randomness (a Chaum-Pedersen
DLEQ) and a one-hot ballot (one disjunctive proof for each slot, bound to
a context word ctx, and a proof of randomness for the sum). The chain
checks them with `ecMul`, `ecAdd` and `hash` (`examples/onehot.lang`).
Rule R17 (S7): a closed `ecrecover` computes in `langc eval`
(`src/front/secp256k1.c`) by the rules of precompile 0x01: v is 27 or 28
and 1 <= r, s < n, else the address 0. A high s is accepted (0x01 has no
EIP-2 rule). An open `ecrecover` is stuck and lowers to a STATICCALL to
0x01. A closed `ecAdd` or `ecMul` computes; `ecPairing` stays stuck.
A domain family can have an index telescope after its
parameters: `family ChoiceBag : Size -> Type 0 := ...`, a Pi
telescope that ends in `Type 0`. Each constructor of an indexed family
states its result after its fields: `choiceNil : ChoiceBag sz0`. A path
constructor states it after its interval fields and before its boundary.
A constructor with no result, a result whose head is not the family at its
parameters, or an end of a path constructor at another index gives
`HIT_INDEX`. The keyword `and` joins the sorts of an inductive-inductive
block: `family Charter := ... and Ratified : Charter -> Type 0 := ...`
(no type parameter: S3 fixes the rule type to `Size`, rule R1). The headers bind first, then the point
constructors of all sorts, then the path constructors. A header that names
its own sort or a later sort of its block gives `BLOCK_ORDER`. A fold over
an indexed family has one constant target, as a fold over a uniform family
does. A fold over a block of n sorts takes n target types (one for each
sort in declaration order), then one case for each constructor of each
sort (sort by sort, in declaration order), then the value. The sorts share
the parameter telescope of the scrutinee (F18, F19).

`elim` also takes a domain family with path constructors (F16, USER ruling
S7). The motive binds the indices and then the value: `P : (n : Size) ->
Bag A n -> Type 0`. A point case takes the fields and an induction binder
after each recursive field or path field. A path case is a PathP over the
motive, and a squash case is a square over the motive. A block sort is
outside `elim`. The DAO prelude (`Config`, `Constitution`, `Aggregation`,
`Tally`, `aggregate`, `gov` and `amend`) follows the last of `orbitProj`
and `outcomeSet`. The program gives the proof slot `def outcomeSet : isSet
Outcome` after `Outcome`, and the slot `def menu : Outcome ->
Constitution` after the prelude. A slot at another type, or a program
definition of a prelude name, gives `REFUSE_SIG`. The domain families
`Pos : Size -> Type 0` (the positions of a bag) and `Word : Size -> Type
0` (the words of adjacent swaps) give the guest theorem `bagOrbit : (n :
Size) -> Equiv (OrbitN n) (Bag Choice n)` (`examples/bagorbit.lang`).

## 3. Type formers

> Write here: only the deviations from the formers. Do not copy the forms.
> Give each former whose status in `formers/tcc-evm-contract.md` is not DONE, and the
> open item (section 9) that records it.

The type formers are F1 to F19 of `formers/FORMERS.md`. This language uses
the tcc-evm-contract column of the realization matrix. `formers/tcc-evm-contract.md` gives
the host form of each former.

| ID | Status on tcc-evm-contract | Effect on this language | Open item |
|---|---|---|---|
| | | | |

## 4. Structures

> Write here: the carriers of Monad (F5), fold and unfold (F6, F7) and
> filter (F8) that the design uses. Name each carrier that the host does not
> give.

- **Monad**: `pure`, `map`, `bind` on <carriers>.
- **Algebra**: `fold` on <carriers>. `unfold` on <carriers>, or the reason
  that there is no `unfold`.
- **Filterable**: `filter` on <carriers>.

## 5. Core types

> Write here (DOMAIN SLOT): only the types of `design/DESIGN.md`. Give each
> type its meaning in the design and its definition in host forms. Mark each
> definition that a probe fact forces with "probe-forced".

| Type | Meaning (design section) | Definition |
|---|---|---|
| `Move` | a move of the token (docs/PLAN.md 3.2) | S3: `Sum (Prod Addr (Prod Addr U256)) (Sum (Prod Addr U256) (Prod Addr U256))` in `examples/mirror.lang`, with the helpers `transfer f t x`, `mint t x` and `burn f x`. A program cannot declare a family (`REFUSE_DATA`). |
| the mirror state | the balances that the hooks keep (3.2) | S3: `bal : Map Addr U256`, `holders : U256`, `holdersIn : Map U256 U256`, `lockEnd : Map Addr Nat`, `bound : Addr`, `decided : Addr`. S5 (Part C, `examples/restrict.lang` only): `used : Map U256 Flag`, `clsOf : Map Addr U256`, `expires : Map Addr Nat`, `ringX : Map U256 U256`, `ringY : Map U256 U256` (a `Map` value cannot be a `List`, so each ring is two slot maps, Q-S5-4 (a)). S6 (Part G, `examples/restrict.lang` only, Q-S6-2 (a), Q-S6-4 (a), Q-S6-5 (a)): `pCapN : U256`, `pCapCN : U256`, `pLockD : Nat`, `pRegD : Nat`, `issuers : Map Addr Flag`, `passCls : Map U256 Flag`. `init` holds the S4 and S5 values. |
| `R.Dec P` | a decided proposition (3.3) | S4, probe-forced: `Sum P (P -> Empty)` (PLAN section 13). `Flag` has no `elim`, so the `rules` form lifts each test to `R.B := Sum Unit Unit` and decides `R.Holds b := Path R.B b R.yes`. |
| `R` (the rules form) | the product of the rules of a token (3.3) | S4: `rules R S M T := r1 \| ... \| rk` gives `R : S -> Env -> M -> Type 0`, the right-nested `Prod` of the `R.rule.ri.holds s e m`. In `examples/restrict.lang`, `R` is `allowed` with the rules `holderCap`, `classCap`, `countryIn` and `lockUp`. |

Source names may have dot-separated identifier components, so a program
can use `R.Dec`, `R.dec`, `R.rule.ri.holds` and `R.rule.ri.dec`. Leading
dots remain internal to generated binders. Per-rule names are separate
from helpers, so tests named `dec`, `bit` or `both` are valid.

## 6. Core operations

> Write here (DOMAIN SLOT): only the operations of `design/DESIGN.md`. Give
> each operation its type and its meaning in the design.

| Operation | Type | Meaning (design section) |
|---|---|---|
| `step` | `State -> Env -> Move -> State` | S3: the hook effect (3.2). `holders` changes only at a zero crossing; `f == t` and `x == 0` change nothing (L6, by `refl` in `examples/mirror.lang`). A mint of `x > 0` moves `lockEnd t` to the later of it and `now + lockD` (Q7). S6 (Q-S6-2 (a)): in `examples/restrict.lang`, `lockD` is the state word `pLockD s`. |
| `transferred`, `created`, `destroyed` | entries | S3: each one runs `step`. Each one reverts unless a token is bound and the caller is that token (L9, `test/run/mirror.script`). No hook reverts for a rule (Q9). |
| `bindToken`, `unbindToken` | entries | S3: apply the DAO decision in the slot `decided` (Q-S3-2 (a)); emit `TokenBound` and `TokenUnbound`. |
| `isTokenBound`, `getTokenBound` | views | S3: the bound token. `getTokenBound` is a view with no parameter (O6). |
| `rules R S M T := r1 \| ... \| rk` | a kit form | S4 (Q-S4-1 (a)): each `ri` is a program def of type `S -> Env -> M -> Flag`. The form elaborates to text (as `cofamily` does): 10 helpers, `R.rule.ri.holds` and `R.rule.ri.dec` for each rule, `R`, `R.dec`, `R.bit` and `canTransfer`. A rule that is not a `Flag` test gives `TYPE_MISMATCH` in its def `R.rule.ri.holds` (O5, `test/check/rules-no-dec.lang`). In guest mode the form gives `REFUSE_KIT`. |
| `holderCap`, `classCap`, `countryIn`, `lockUp` | `State -> Env -> Move -> Flag` | S4: the rule tests of `examples/restrict.lang`. `holderCap`: `holders (step s e m) <= capN`. `classCap`: `holdersIn (step s e m) capC <= capCN`. `countryIn`: `inSet (clsCode s t)` (S5: the class of `t`, Q-S5-3 (a)). `lockUp`: `lockEnd s f <= now e`, with `f` from `moveFrom` (`noAddr` for a mint, Q-S4-5 (a)). A cap decides on the state after the move (L3). S6 (Q-S6-2 (a)): `capN` is the state word `pCapN s`, `capCN` is `pCapCN s`, and `countryIn` is `inSet s (clsCode s t)`. |
| `canTransfer` | `(env : Env) -> (s : State) -> (f t : Addr) -> (x : U256) -> Flag` | S4: a view, the first bit of `R.dec s env (T f t x)` (L1 by construction). Mint and burn are not checked (the EIP bypass). |
| `transferred` (S4) | entry | S4 (Q-S4-6 (a)): in `examples/restrict.lang`, `transferred` emits `Broken f t x` when `canTransfer` is no on the state before the move, and it still runs `step` (Q9). `created` and `destroyed` do not emit it. |
| `zkHpAt` | `G1 -> U256 -> G1` | S5 (Q-S5-1 (a), O8): `zkHpAt P w` is the try and increment hash to curve from the seed `hash (hash P.x P.y) w`. `zkHp P` does not change (the seed `hash P.x P.y`). |
| `zkSignAt`, `zkVerifyAt` | `zkSignAt ring x w m : List U256`, `zkVerifyAt ring w m sig : Flag` | S5 (Q-S5-1 (a)): the bLSAG of `zkSign` with `H_i = zkHpAt P_i w` and the key image `I = x * zkHpAt (x * G) w`. `w` is the context and goes into the poll place of the challenge; `m` goes into the choice place. One key gives one key image in one context and another key image in another context. `zkSign` and `zkVerify` give the same bytes as before (`test/blsagtool.c`). An open `w` in `zkVerifyAt` stays stuck. |
| `cls`, `inSet` | `U256 -> U256`, `U256 -> Flag` | S5 (Q-S5-3 (a)): in `examples/restrict.lang`, `cls` maps the country set S1 = {840} to class 1 and the other countries to class 0, by hand (O17: the rules form does not compute it yet). `countryIn` reads `inSet (clsCode s t)`, and `inSet` lets class 0 pass. Two countries of one class get the same answer (L2, by `refl`). S6 (Q-S6-5 (a)): `inSet : State -> U256 -> Flag` reads the class pass set `mapGet (passCls s) k`. `init` lets class 0 pass. |
| `issue` | entry | S5 (Q-S5-4 (a)): `issue c i kx ky` writes the key `(kx, ky)` into slot `i` of class `c` (the keys `c + c + i` of `ringX` and `ringY`) and emits `Issued c i`. It reverts unless the caller is `issuer` and `i <= 1`. S6 (Q-S6-4 (a)): the issuers are the state map `issuers`, and `issue` reads `mapGet (issuers s) (caller env)`. `init` holds the S5 issuer `issuer0`. |
| `register` | entry | S5 (Q-S5-5 (a)): `register c c1 s1 s2 ix iy` verifies the signature `c1 s1 s2 ix iy` by `zkVerifyAt (ring s c) (addrToU256 self) caller`. It reverts on a bad signature, on a used key image (`used (hash ix iy)`, L7), and when the caller holds tokens and `c` is not its class. Else it sets `used`, `clsOf caller = c` and `expires caller = now + regD`, and emits `Registered c ix iy`. S6 (Q-S6-2 (a)): the registration length is the state word `pRegD s`. |
| `isVerified` | `(env : Env) -> (s : State) -> (w : Addr) -> Flag` | S5 (Q-S5-6 (a)): a view, `now < expires s w` (L8). An address that did not register has the end 0. `clsCode s a` is `clsOf s a`, so such an address has class 0. |
| `withGov`, `setCapN`, `setCapCN`, `setLockD`, `setRegD`, `setIssuer`, `setPass` | `State -> ... -> State` | S6 (Q-S6-2 (a), Q-S6-4 (a), Q-S6-8 (a)): the setters of the Part G words in `examples/restrict.lang`. `withGov` writes the six words. Each setter (`setParam` for each word, `setIssuer a f`, `setPass k f`) changes one word, and the `refl` rows show that the other words stay. No entry calls them in S6: the entries `propose`, `ballot`, `openTally` and `enact` are S7. |
| `active` | `Charter -> RuleSet` | S6 (Q-S6-5 (a)): in `examples/charter.lang`, the fold of the charter history to the active rule-set id (`rs0` is the S4 rule set, `rs1` is the S6 rule set). An amendment changes the Part G words. A new rule kind is a new contract. |
| `yn`, `passCon`, `regimeOf` | `Choice -> Choice -> Choice`, `Constitution`, `(Outcome -> Constitution) -> Tally -> Regime` | S6 (Q-S6-3 (a), Q-S6-6 (a)): in `examples/charter.lang`, `act` swaps the two members. `yn` is the yes or no rule, and `passCon` is its constitution. A tie gives no, so the old value stays. `regimeOf` counts the self-constituting outcomes of a menu: the yes or no menu gives AD at each orbit, and the echo menu gives SI at the tie. |
| the ballot context | `pctx := hash selfWord pid` | S6 (Q-S6-1 (a), Q-S6-7 (a)): `examples/ballot.lang` (the port of intent-lang S9) verifies a ballot by `zkVerifyAt ring pctx`. Thus a ballot of one proposal does not verify in another proposal (`test/ballottool.c`, the row "ballot in a second proposal"). The guest `zkVerify` keeps poll 0. |
| | | |

## 7. Target and instance encoding

> Write here: what the compiler writes. For a JSON target, give the instance
> rule and the encoding table. For a contract target, give the storage, the
> entries and the guards. Say how each proof erases.

An instance is a top-level definition whose type is a data type (F14).

| Type | Encoding |
|---|---|
| | |

## 8. Host and target

> Write here: the host, its pinned commit (`PIN`), the facts from
> `probe/CAPABILITY.md` that set the design, and the check that the compiler
> runs on its output (for example the axiom report).

## 9. Open items

> Write here: one item for each open question. Number the items O1, O2 and
> so on. Mark each decision as "RULED YYYY-MM-DD (USER): <the ruling>". Mark
> each fact that a probe found as "Probe-forced".

- O1. <question>.

## 10. Milestones

> Write here: the content of each milestone, and a dated status line under
> the current milestone.

| Milestone | Content |
|---|---|
| M0 | Host probe (`probe/CAPABILITY.md`); the core types construct and check; refusal list; examples and tests |
| M1 | Core operations |
| M2 | Queries and reads, or the contract |
| M3 | Hardening: speed, limits, a checked certificate for the output |
