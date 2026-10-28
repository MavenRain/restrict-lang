# restrict-lang specification

Status: S0 to S8 DONE, S8 CLOSED 2026-10-27; the plan is closed. The name
is O1 (kept). The counts in this file are the counts of the S8 s5 final
gate (`make -B check`, serial, EXIT 0). The log is byte for byte the S8
s3 step0 log: no count changes.

## 1. Purpose

restrict-lang is a language for the transfer rules of tokenized assets
(ERC-3643). Its compliance model covers one token:
the rules (holder caps, class caps, country rules and lock-ups), the
identity claims as ZK credentials, and the parameters that the DAO
governs. A rule is a type: a decidable proposition `State -> Env -> Move
-> Type 0`. The rule set `Allowed` is the product of the rules
(`docs/PLAN.md` 3.3 and 4.1).

The compiler checks a program in Cubical TT (`langc [--kit] check`) and
evaluates closed terms (`langc [--kit] eval`). The deployable examples are
the separate compliance and DAO programs, built with `langc --kit build`
(section 7). The host is TinyCC (rule R4) with the kit
tcc-evm-contract. The target is the EVM.

The type formers are F1 to F19 of `formers/FORMERS.md`. For type
constructors and higher kinds, the formers are only cell monads and their
duals (rule R1): a family with a type parameter must be a cell signature,
and a cofamily must be a cocell signature (section 2). The checker of
intent-lang ef5abe8 enforces R1, and the S2 port carries it. restrict-lang
adds no type constructor. Its core data types and core operations are only
the types and operations of `design/DESIGN.md` (the design), at the
minimum that the pasted description needs (rule R2). The DAO of
orbit-lang, as intent-lang carries it, governs each contract that
restrict-lang writes (rule R3, Q2 (a)). The design assigns each parameter,
the issuer list, the binding and the rule set to the DAO. The linked S7
contracts implement votes for four numeric parameters; section 7 records
the remaining governance limits. The owner and agent roles of the token
stay with the issuer.

## 2. Programs

A program is a sequence of definitions:

```
def NAME : TYPE := TERM
```

The compiler refuses a program form that `formers/tcc-evm-contract.md`
does not give. The gate checks each refusal by its code. The refusal
codes of `test/check/expect.txt` are `REFUSE_AXIOM`, `REFUSE_CALL`,
`REFUSE_CELL`, `REFUSE_DATA`, `REFUSE_EVENT`, `REFUSE_HISTORY_WRITE`,
`REFUSE_KIT`, `REFUSE_LAW`, `REFUSE_MAP`, `REFUSE_NAME`, `REFUSE_REC`,
`REFUSE_SIG` and `REFUSE_STATE`. The S8 s5 final gate checks 19 parse
refusals, 193 check refusals and 15 run refusals. Of the check refusals,
23 are kit-only rows: `langc check` rejects them with `REFUSE_KIT`, and
`langc --kit check` accepts them.
The compiler also refuses a definition that uses a core name or
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

The type formers are F1 to F19 of `formers/FORMERS.md`. This language uses
the tcc-evm-contract column of the realization matrix.
`formers/tcc-evm-contract.md` gives the host form of each former. The S2
port carries the formers of intent-lang ef5abe8, and restrict-lang changes
none of them (`docs/PLAN.md` section 2). The table gives each form whose
status in `formers/tcc-evm-contract.md` is not DONE in both columns.

| ID | Status on tcc-evm-contract | Effect on this language | Open item |
|---|---|---|---|
| `ecrecover` | eval OPAQUE; EVM DONE (STATICCALL to 0x01) | Rule R17 (section 2, from the port) makes a closed `ecrecover` compute in `langc eval`. The formers file still says OPAQUE. No restrict-lang rule uses it. Only the ported example `examples/precompile.lang` uses it. | O14 |
| `ecAdd`, `ecMul` | eval OPAQUE; EVM DONE (STATICCALL to 0x06 and 0x07) | Rule R17 makes a closed application compute in eval. The formers file still says OPAQUE. | none |
| `ecPairing` | eval OPAQUE; EVM DONE (STATICCALL to 0x08 over a closed list of pairs) | A closed application stays stuck in eval (rule R17). | none |
| `funExt` | DONE in `check` only; erased on the EVM | A path proof only: no contract value depends on it. | none |

## 4. Structures

- **Monad**: `pure`, `map`, `bind` on `Option` and `Sum E`, on `FreeMon`
  (`fmEta`, `fmMap`, `fmBind`) and on the sealed `Enc` (`encEta`,
  `encMap`, `encBind`). `domain/domain.lang` gives `FreeMon` and `Enc`.
  The kit `List` is the host ABI only: a guest uses `FreeMon` (section 2).
- **Algebra**: `fold` on the domain families, for example `Size`,
  `FreeMon`, `Bag`, `ChoiceBag`, `Pos`, `Word` and the block of `Charter`.
  `active` is a fold of the charter history (section 6). `unfold` on the
  cofamily `Stream` (the corecursor `sCorec`). restrict-lang adds no
  carrier.
- **Filterable**: `filter` on `Option`. The filter of a `FreeMon` is a
  bind (`examples/monad.lang`).

## 5. Core types

| Type | Meaning (design section) | Definition |
|---|---|---|
| `Move` | a move of the token (docs/PLAN.md 3.2) | S3: `Sum (Prod Addr (Prod Addr U256)) (Sum (Prod Addr U256) (Prod Addr U256))` in `examples/mirror.lang`, with the helpers `transfer f t x`, `mint t x` and `burn f x`. A program cannot declare a family (`REFUSE_DATA`). |
| the mirror state | the balances that the hooks keep (3.2) | S3: `bal : Map Addr U256`, `holders : U256`, `holdersIn : Map U256 U256`, `lockEnd : Map Addr Nat`, `bound : Addr`, `decided : Addr`. S5 (Part C, `examples/restrict.lang` only): `used : Map U256 Flag`, `clsOf : Map Addr U256`, `expires : Map Addr Nat`, `ringX : Map U256 U256`, `ringY : Map U256 U256` (a `Map` value cannot be a `List`, so each ring is two slot maps, Q-S5-4 (a)). S6 (Part G, `examples/restrict.lang` only, Q-S6-2 (a), Q-S6-4 (a), Q-S6-5 (a)): `pCapN : U256`, `pCapCN : U256`, `pLockD : Nat`, `pRegD : Nat`, `issuers : Map Addr Flag`, `passCls : Map U256 Flag`. `init` holds the S4 and S5 values. |
| `R.Dec P` | a decided proposition (3.3) | S4, probe-forced: `Sum P (P -> Empty)` (PLAN section 13). `Flag` has no `elim`, so the `rules` form lifts each test to `R.B := Sum Unit Unit` and decides `R.Holds b := Path R.B b R.yes`. |
| `R` (the rules form) | the product of the rules of a token (3.3) | S4: `rules R S M T := r1 \| ... \| rk` gives `R : S -> Env -> M -> Type 0`, the right-nested `Prod` of the `R.rule.ri.holds s e m`. In `examples/restrict.lang`, `R` is `allowed` with the rules `holderCap`, `classCap`, `countryIn` and `lockUp`. |
| `Env` (S7) | the block and the caller of a hook (3.2) | S7 s2 (Q-S7-3 (a), Q-S7-6 (a)): the port of intent-lang S8 and S10 gives the `Env.block` prelude. The field `self : Addr` lowers to ADDRESS (0x30). A run script sets it with the line `env SELF`. The constant `self` is now `selfAddr` (rule R4), and `makeEnv` takes a fourth argument. |
| the kit contract state | the mirror state of the contract (section 7) | S7 s3 and s4: `examples/restrictkit.lang` is the contract that the kit builds. S7 s4 adds the init field `dao : Addr`. |
| the DAO state | the proposals of the DAO over the rules (3.1) | S7 s5 and s7: `examples/restrictdao.lang` keeps the proposal id and the kind of each proposal. The ballot context `ctxOf` and the nullifier `nullOf` are at `pid s` (S7 s7). |

Source names may have dot-separated identifier components, so a program
can use `R.Dec`, `R.dec`, `R.rule.ri.holds` and `R.rule.ri.dec`. Leading
dots remain internal to generated binders. Per-rule names are separate
from helpers, so tests named `dec`, `bit` or `both` are valid.

## 6. Core operations

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
| `toNat` | `U256 -> Nat` | S7 s2 (Q-S7-4 (a)): a kit op. Nat is an ABI `uint64`. Eval traps above 2^64 - 1, and the lowering reverts (an IF with a TRAP arm). |
| `allowed.bit` | `State -> Env -> Move -> Flag` | S7 s2 (Q-S7-2 (a)): the rules form builds it from the rule bits at the supplied state, environment and move. |
| `zkHpAt` on the chain | `G1 -> U256 -> G1` | S7 s3 (Q-S7-10 to Q-S7-14): the H_p loop `lower_hp` with K = 8 tries (`RESTRICT_HP_TRIES`) and MODEXP (precompile 0x05). In eval, an open `zkHpAt` is an opaque term. `issue` takes the counter hc as a fifth word and checks `hpAt` at `selfWord` (Q-S7-13 (a)). |
| the setters | entries | S7 s4: `examples/restrictkit.lang` has 7 setter entries (`setCapN`, `setCapCN`, `setLockD`, `setRegD`, `setIssuer`, `setPass` and `setDecided`), and each one has the check `fromDao` (section 7). |
| the kit CALL form | a call in an entry | S7 s5 (Q-S7-17 (a), Q-S7-18 (a)) introduces the `setCapN` call. S7 s7 makes `enact` select one of the four numeric restrictkit setters by proposal kind (section 7). |
| `propose`, `enact`, `pidNow`, `kindNow` | entries and views | S7 s7: `propose` takes the pid, checks the counter bounds before each `hpAt`, and keeps the kind. `enact` gives the output of each kind. The proposer is the t8n key address (Q-S7-26 (a)). `sigOk` takes the word w (Q-S7-28 (a), O18). |

## 7. Target and instance encoding

The deployable compliance example is `examples/restrictkit.lang`; its
linked DAO is the separate `examples/restrictdao.lang` contract. Build
each with `langc --kit build PROG`. The general rules model in
`examples/restrict.lang` checks under `--kit`, but its kit build currently
gives `REFUSE_LOWER` at `canTransfer`. The guest `langc contract` writer
requires a guest DAO prelude and rejects that model with `REFUSE_KIT`.
Checking a rules program alone does not produce a compliance contract.
The kit maps `Flag` to `bool`, `U256` to
`uint256`, `Addr` to `address` (H:200) and `Nat` to `uint64` (Q-S7-4).

Storage in restrictkit: the mirror state of section 5 (S3), the class and
ring maps of Part C (S5), the DAO parameters, issuer list and class passes
(S6), and the init field `dao` (S7 s4).

| Entry or view | ABI | Effect and guard |
|---|---|---|
| `bindToken` | `bindToken(address)` | Applies the DAO decision in the slot `decided`; emits `TokenBound` |
| `unbindToken` | `unbindToken(address)` | Applies the DAO decision; emits `TokenUnbound` |
| `isTokenBound` | view `isTokenBound(address) -> bool` | |
| `getTokenBound` | view `getTokenBound() -> address` | A view with no parameter (O6) |
| `canTransfer` | view `canTransfer(address,address,uint256) -> bool` | The conjunction of the four rule bits, corresponding to the `Dec` result of `Allowed` (L1) |
| `transferred` | `transferred(address,address,uint256)` | Reverts unless a token is bound and the caller is that token (L9); runs `step`; emits `Broken` when `canTransfer` says no |
| `created` | `created(address,uint256)` | The guard of L9; runs `step`; sets `lockEnd` |
| `destroyed` | `destroyed(address,uint256)` | The guard of L9; runs `step` |
| `isVerified` | view `isVerified(address) -> bool` | `now < expires s w` (L8); the identity registry view (Q3 (a)) |
| `issue` | entry | An issuer that the DAO lists adds a key to the ring of a class; checks `hpAt` at `selfWord` with the counter hc |
| `register` | entry | The bLSAG check with the per-contract key image (3.4); stores `clsOf`, `expires` and `used` |
| the setters | entries | The check `fromDao` (S7 s4) |
| separate DAO entries | `propose`, `castSig`, `castSlot`, `castSeal`, `enact` and views | Encrypted votes over the four numeric settings (`examples/restrictdao.lang`); the tally opens inside `enact` |

The linked DAO supports kinds 0 to 3: `setCapN`, `setCapCN`, `setLockD`
and `setRegD`. `propose` requires the fixed proposer, a block after
`castEnd`, an increasing pid, and valid H_p counters at the context
`hash(selfWord, pid)`, each bounded by 7 before its `hpAt` check. Duration
proposals (kinds 2 and 3) must fit 2^64 - 1. `enact` requires the voting window to
have ended, a valid tally opening and no earlier enactment. A strict yes
majority emits the selected call; a tie emits no call.

The seven restrictkit setters accept only its stored DAO address. The
linked DAO has no vote or call path for `setIssuer`, `setPass` or
`setDecided`, so its issuer list, class passes and binding decision remain
at their initial values. The charter and rule-set amendment laws are
checked in `examples/charter.lang`; the linked DAO does not execute those
amendments. These governance paths remain implementation limits of S7.

Events: `TokenBound(address)`, `TokenUnbound(address)` (EIP), `Issued`,
`Registered` (the class and the key image only) and `Broken` (Q9 (a)). A
hook does not revert on a rule. A forced transfer is a move that `Allowed`
can refuse: the hook runs `step` and emits `Broken`.

The token points at this contract twice: as its compliance and as its
identity registry (Q3 (a)). The contract does not serve
`investorCountry`: the country is hidden (O12).

Erasure: a proof does not go on the chain. The rules model relates its
Boolean result to the `Dec` term of `Allowed` (L1); the deployed
`canTransfer` computes the rule bits directly. Paths, `sym`, `cong` and
`funExt` erase. The checked ideal model uses `ZKProof W := Trunc1 W`.
The deployed `register` entry verifies caller-supplied bLSAG words (3.4)
with `ecMul`, `ecAdd`, `hash` and MODEXP. The compiler does not translate
an arbitrary `ZKProof W` into a bLSAG verifier.

Size (the S8 s5 final gate): the restrictdao contract
(`examples/restrictdao.lang`, `rdao` in `test/dao.sh`) has a runtime of
23909 bytes (limit 24576, EIP-170) and an initcode of 23949 bytes (limit
49152).
The ported dao contract has a runtime of 16702 bytes and an initcode of
16737 bytes. `test/dao.sh` gives 89 chain steps and 0 failures.

## 8. Host and target

The host is TinyCC (rule R4). PIN: tcc 0.9.28rc 2026-09-04
mob@0fb54300 (`docs/host/CAPABILITY.md`). The kit is tcc-evm-contract
(`docs/host/README.md`). lang-template made the kit, and orbit-lang and
intent-lang use it. S2 ports it with the kernel of intent-lang ef5abe8
(`docs/PLAN.md` section 6). S7 s2 ports intent-lang S8
(`ef5abe8..c6636f1`) and S10 (`3df9d96..79e1898`). `probe/CAPABILITY.md`
is still the template of the seed. The probe facts are in
`docs/host/CAPABILITY.md`, `docs/host/README.md` and the probe rows of
`docs/PLAN.md`.

The probe facts that set the design:

- At S0 the kit CALLs only `pay` and `pull` (H:88). Thus the hooks keep a
  mirror of the balances (3.2, O16). S7 s5 adds the kit CALL form
  (Q-S7-17 (a)).
- The bLSAG verifier is unrolled for a ring of fixed size n (H:318).
- The guest poll id is 0 (H:310). Thus the ballot context is `hash
  selfWord pid` through `zkVerifyAt` (O15).
- `Flag` has no `elim`. Thus `R.Dec` is probe-forced (section 5, S4).
- A `Map` value cannot be a `List`. Thus each ring is two slot maps
  (Q-S5-4 (a)).
- The S7 s1 probes p1 to p7: the writer refuses the kit file, and the kit
  build refuses `either` and `zkVerifyAt` over a state ring or a run-time
  context word (`docs/PLAN.md` section 16).
- A State argument to a def that holds `zkVerifyAt` adds about 6.3 KB of
  runtime (O18).
- The runtime limit is 24576 bytes (EIP-170). The initcode limit is 49152
  bytes.

The check on the output: `make -B check` (serial) runs the kit gate. It
checks the examples, the refusals, the evals, the runs, the contract
writer, the differential rows (the guest evals against the chain), the
chain rows on the test token (Q13), the size rows and the gas rows. The S8
s5 final gate: 60 examples and 0 failed, 257 evals, 28 differential guest
evals, EXIT 0.

## 9. Open items

Each item is RULED, CLOSED or kept as the builder call (`docs/PLAN.md`
section 10). The S1 ruling (2026-10-24, USER: "Rulings: Take all
recommendations") gives Q1 to Q14 (a).

- O1. The name: restrict-lang, from the title of the paste. Builder call.
  Kept.
- O2. The target: the EVM by tcc-evm-contract. ERC-3643 is an EVM
  standard. Builder call. Kept.
- O3. The kernel: port intent-lang ef5abe8. RULED 2026-10-24 (USER): Q1
  (a). Done in S2.
- O4. The `rules` form: a top-level form that elaborates to definitions
  (text elaboration). The contract needs the rule names for the `Params`
  of each rule. Kept. Done in S4 (Q-S4-1 (a)).
- O5. Decidability: a rule must have a `dec` term. A rule with no `dec`
  term gives `TYPE_MISMATCH` (no dedicated code). Kept.
- O6. The ABI names: the kit must accept the exact ICompliance names and a
  view with no parameter (`getTokenBound()`). CLOSED (S7, Q-S7-8 (a)): the
  ABI row of `test/restrict.sh` checks 9 EIP selectors (S7 s4).
- O7. The mirror is correct only if the token calls a hook for each
  balance change, forced transfers and recovery too. The chain rows test
  the test token only. RULED 2026-10-24 (USER): Q13 (a). Kept.
- O8. The per-contract key image needs a hash to curve. RULED 2026-10-24
  (USER): Q4 (a). CLOSED (S5, Q-S5-1 (a)): `zkHpAt`. S7 s3 lowers it to
  the chain (MODEXP 0x05, K = 8 tries).
- O9. Encrypted ballots. CLOSED (S6, USER, Q-S6-1 (a)): restrict-lang
  ports the intent-lang S9 form.
- O10. The design calls for ring expiry, revocation by replacing the ring
  without the key, and invalidation when the classes change. The current
  `isVerified` checks only the wallet's stored expiry. Replacing a ring
  key or removing an issuer leaves an existing registration live until
  that expiry; ring and class changes do not invalidate registrations.
  A wallet whose registration expires keeps its tokens and cannot receive
  more. Kept: invalidation on ring or class changes is unimplemented.
- O11. Two credentials from two issuers give two wallets. A per-investor
  cap is a per-credential cap. The charter binds each issuer to one
  credential for each investor and class. Kept.
- O12. `investorCountry(address)` is not served: the country is hidden.
  RULED 2026-10-24 (USER): Q5 (a).
- O13. The UAT regime of each vote kind. CLOSED (S6, USER, Q-S6-6 (a)):
  each vote kind is Arrow-Debreu (`examples/charter.lang`).
- O14. `ecrecover` comes with the port. The ported precompile example uses
  it; no restrict-lang rule uses it. Kept: S2 keeps it.
- O15. The guest poll id is 0 (H:310). Probe-forced. CLOSED (S6, USER,
  Q-S6-7 (a)): no signature change. The ballot context word is
  `hash(selfWord, pid)` through `zkVerifyAt`.
- O16. The transfer agent: the token stays the record of ownership. The
  contract keeps a mirror only (3.2). Kept.
- O17. The class map `cls` is written by hand in `examples/restrict.lang`
  (S5, Q-S5-3 (a)): S1 = {840} gives class 1, and the other countries
  give class 0. The rules form can compute `cls` from the sets of its
  rules (a change to `check_rules`, Q-S5-3 (b)). Kept: open.
- O18. A State argument to a def that holds `zkVerifyAt` adds about 6.3 KB
  of runtime, also when the body does not read it. Probe-forced. RULED
  (USER, S7 s7): Q-S7-28 (a), `sigOk` takes the word w. The cause in the
  lowering is not probed. RULED 2026-10-27 (USER): Q-S8-6 (b), no probe.
  Kept: open.

## 10. Milestones

The milestones are the slices of `docs/PLAN.md` section 9.

| Slice | Content | Status |
|---|---|---|
| S0 | Generate from lang-template (tcc-evm-contract); the design verbatim; the plan; README; the kit gate | DONE (2026-10-24) |
| S1 | The USER rules Q1 to Q14; the plan records the rulings | DONE (2026-10-24) |
| S2 | Port intent-lang ef5abe8; the gate gives the intent-lang S7 counters | DONE (2026-10-24) |
| S3 | Part T: `Move`, the mirror state, `step`, the hooks with L9, the binding; L6 | DONE (2026-10-24) |
| S4 | Part R: the `rules` form (O4), `Dec`, `Allowed`, `canTransfer`; the four rule kinds; L1, L3, L4 | DONE (2026-10-24) |
| S5 | Part C: the class partition, the issuer rings, `register` with the per-contract key image (O8), `isVerified`, expiry; L2, L7, L8 | DONE (2026-10-25) |
| S6 | The DAO over the rules: `Params` for each parameter, the issuer list, rule-set amendment, encrypted ballots (O9) | DONE (2026-10-25) |
| S7 | The contract writer: the ABI of section 7, the events, the entries of Q-S6-8 (a), the chain rows on the test token (Q13) | DONE (s1 to s7, 2026-10-25 to 2026-10-27) |
| S8 | Mutants, SPEC, VALIDATION, close | DONE (s1 to s5, 2026-10-27); CLOSED |

Status (2026-10-27): S0 to S8 DONE. S8 s2 killed the mutants N1 to N5.
The sum of S3 to S8 is 80 KILLED, 2 equivalent and 0 SURVIVED. S8 s3
filled this file. S8 s4 rewrote `docs/VALIDATION.md` and `docs/STATUS.md`.
The S8 s5 final gate passed (EXIT 0). Closed at S8 (2026-10-27): the plan
is closed.
