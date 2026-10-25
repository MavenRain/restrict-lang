# restrict-lang plan

restrict-lang is a Cubical TT language for the transfer rules of tokenized
securities. A program declares the rules of one token (holder caps, country
rules, lock-ups), the ZK credentials that prove identity claims, and the DAO
that governs them. The compiler checks the laws and writes the EVM bytecode
of an ERC-3643 compliance contract. `design/DESIGN.md` holds the request and
the design verbatim.

In this file, "intent-lang" means MavenRain/intent-lang at ef5abe8 (tree
da87a361, S7 closed). "P" is its `docs/PLAN.md`, "D" is its
`domain/domain.lang` and "H" is its `docs/host/README.md`. "resolve-lang"
means MavenRain/resolve-lang at a1624ab (S1 closed). "EIP" means the text of
ERC-3643 at eips.ethereum.org/EIPS/eip-3643 (read 2026-10-24).

## 1. Rulings

USER rulings (the request, 2026-10-24):

- R1 type formers: for type constructors and higher kinds, only cell monads
  and their duals, in a locally presentable, locally cartesian closed
  (infinity,1)-category, as Cubical TT represents it.
- R2 base types and operations: the minimum that satisfies the pasted
  description (the bullet "The language").
- R3 governance: a UAT-respecting ZK FHE MPC self-referential DAO governs
  all contracts. The paste names no DAO. The builder reading is the DAO of
  orbit-lang, as intent-lang carries it (3.1).
- R4 host: TinyCC.

USER rulings (S1, 2026-10-24), verbatim:

> Rulings: Take all recommendations

So each question of section 11 takes its recommendation (a):

- Q1 (a): S2 ports the kernel of intent-lang ef5abe8 (section 6). R1 is
  already enforced there.
- Q2 (a): the DAO governs each contract that restrict-lang writes. It owns
  each parameter, the issuer list, the binding and the rule set. The owner
  and agent roles of the token stay with the issuer (3.1).
- Q3 (a): the contract also serves `isVerified(address)`, and the token
  uses it as its identity registry (3.4, section 7).
- Q4 (a): a bLSAG over the issuer ring of each class, with a key image for
  each contract (4.3).
- Q5 (a): a holder discloses the class only, not the country (4.2).
- Q6 (a): the unit of a holder is a wallet. One credential registers one
  wallet in each contract (4.3, L7).
- Q7 (a): one lock end for each wallet. `created` sets it to `now + d`, a
  later mint moves it to the later time, and a transfer in does not lock
  (3.3).
- Q8 (a): the clock is `now`, which lowers to TIMESTAMP (seconds). Holding
  periods are calendar time (3.3).
- Q9 (a): the hooks never revert for a rule. A forced move updates the
  mirror, and the hook emits `Broken` (section 7).
- Q10 (a): the DAO votes yes or no on one proposal (May, 4.4).
- Q11 (a): a country rule reads the receiver only (3.3).
- Q12 (a): a total cap and a cap for each class (3.3).
- Q13 (a): the chain rows use a test token in the kit test style. It calls
  `isVerified`, `canTransfer` and the hooks in the order of the EIP example
  (section 8).
- Q14 (a): the DAO members are the members that the charter lists, ported
  (3.1).

Builder calls (section 10 gives each one; Q1 rules O3):

- O1: the name restrict-lang, from the title of the paste ("A
  transfer-restriction language").
- O2: the target is EVM bytecode, with the kit hosts/tcc-evm-contract.
  ERC-3643 is an EVM standard, so the paste fixes the chain family.
- O3: the kernel comes from intent-lang ef5abe8, as for resolve-lang. R1 is
  already enforced there (section 6). RULED: Q1 (a).
- The "Activity" bullets are motivation. The plan does not check them, and
  no type or operation comes from them. The GENIUS Act bullet is about
  stablecoins, not securities. No rule comes from it.
- Tests are guest-language files plus `langc run` scripts. The kit gate
  scripts stay. We add no new harness.

## 2. The reading of R1

R1 has the same words as the type-former ruling of intent-lang. intent-lang
P section 2 gives the reading, and its S3 and S4 put it in the checker. The
S2 port (section 6) carries that checker. restrict-lang does not build it
again.

| Part | Cubical TT | R1 limit |
|---|---|---|
| Ambient | Pi, Sigma, `Path`, `PathP`, `I`, `i0`, `i1`, `transp`, `hcomp`, `U`, `Glue`, `ua`, the builtin `Sum` and `Unit` | none: the internal language of the category |
| CM, cell monad | a `family` with a type parameter: the parameter is the one field of one generator; each other field is closed base data, the family at its own parameters, or a path in it | else `REFUSE_CELL` |
| CC, cocell comonad | a `cofamily` with one observation `A` and cofields `D A` or `E -> D A` | else `REFUSE_CELL` |

Only `domain/domain.lang` declares a family or a cofamily. A program that
declares one gets `REFUSE_DATA`. A family with no type parameter is a base
type, not a type constructor. R2 limits it, not R1.

What R1 means for restrict-lang:

- A rule is not a type constructor. It is a family of propositions over a
  state and a move, `State -> Move -> U`. Its parameters are values, not
  types, so it is a Pi type into `U`: ambient.
- Country sets, classes and claim topics are closed base data. A program
  writes a class set as a nested `Sum` of `Unit`, as intent-lang does
  (`examples/regimes.lang:6`).
- A ZK credential is a term of `ZKProof W := Trunc1 W` (D:159). `Trunc1` is a
  cell monad: the generator `|_|` holds the parameter and `squash` is a
  1-cell. It comes with the port.
- restrict-lang adds no type constructor in v1. A later slice that needs one
  must pass the `REFUSE_CELL` check.

## 3. The minimal base signature (R2)

Each type and operation below answers one part of the paste or of R3. The
table gives the part, the minimum and the reading.

| Part | Minimum | Reading |
|---|---|---|
| ERC-3643 token moves | `Move`, the mirror state, `step` | 3.2 |
| compliance rules stated as types | `Rule`, `Dec`, `Allowed`, the `rules` form | 3.3, 4.1 |
| holder caps | `HolderCap n`, `ClassCap c n` | 3.3 |
| country rules | `CountryIn S` over `Class` | 3.3, 4.2 |
| lock-ups | `LockUp d`, `lockEnd` | 3.3 |
| identity claims as ZK credentials | `Class`, `cls`, issuer rings, `register`, key image for each token | 3.4, 4.3 |
| compile to an ERC-3643 compliance contract | the ICompliance entries and views | section 7 |
| the DAO governs all contracts | the ported DAO, `Params`, rule-set amendment | 3.1, 4.4 |

### 3.1 Part D: the DAO

Part D is the DAO of intent-lang (P 3.1 and 3.4). It comes with the S2 port.
The S2 port changes no name.

- Kit base data: `U256`, `Addr`, `Nat`, `Flag`, `Env` (`now`, `caller`),
  `Out` (`pay`, `pull`, `emit`), `Map K V`, the contract state.
- Slots: `Member`, `Choice`, `Group`, `Decision` (one value of `Params`).
- Defined: `Config`, `Orbit` (= `Config / act`), `Constitution`,
  `Aggregation`, `Tally`, `act`, `orbitProj`, `aggregate`, `gov`, `amend`.
- Self-reference: `Charter` and `Ratified` (D:217-223). The DAO amends its
  own charter by its own vote.
- ZK: `ZKProof W := Trunc1 W` (D:159), `Transcript`, the law `verified`,
  Sigma verifiers by Fiat-Shamir, bLSAG ring ballots.
- FHE: the sealed `Enc` monad (D:136), law-only `decrypt` and `observe`,
  exponential ElGamal on BN254 in the host.
- MPC: `Quorum` and the law `open` (D:149-151). The members hold threshold
  shares. The chain checks one DLEQ proof for each share.
- UAT: aggregation is the left Kan extension along the voter-orbit quotient
  (orbit-lang `design/DESIGN.md:39`, from MavenRain/self-referential-dao).
  The orbit quotient makes the vote anonymous.

"Govern all contracts" (Q2 (a)): restrict-lang writes one contract for each
program, and the DAO is part of it. Each parameter of 3.3, the issuer list
of 3.4, the token binding and the rule set itself are DAO decisions. No
other key can change them. A new rule set is a charter amendment: the DAO
changes the rules by its own vote (4.4).

### 3.2 Part T: the token moves

ERC-3643 calls the compliance contract on each move of the token (EIP,
ICompliance): `transferred(from, to, amount)`, `created(to, amount)` and
`destroyed(from, amount)`. ICompliance gives no balance read, and the kit
makes no CALL except `pay` and `pull` (H:88). So the contract keeps a mirror
of the balances, and the hooks keep it current.

| Name | Type | Note |
|---|---|---|
| `Move` | base data: `transfer (f t : Addr) (x : U256)`, `mint (t : Addr) (x : U256)`, `burn (f : Addr) (x : U256)` | no type parameter |
| `bal` | `Map Addr U256` | the mirror of the token balances |
| `holders` | `U256` | the number of addresses with `bal > 0` |
| `holdersIn` | `Map U256 U256` | the holders of each class code |
| `lockEnd` | `Map Addr Nat` | the end of the lock-up of each address |
| `step` | `State -> Env -> Move -> State` | the hook effect: balances, counts, lock ends |

`step` changes `holders` only at a zero crossing: `+1` when `bal t` goes
from 0 to more than 0, `-1` when `bal f` goes to 0. A move with `f == t`
and a move with `x == 0` change no count.

S3 (DONE, 2026-10-24) is `examples/mirror.lang` and the run script
`test/run/mirror.script`. The kernel does not change. Surprises:

- `Move` is a Sum alias with three helpers, not base data (Q-S3-4 (a)): a
  program cannot declare a family.
- A move with `f == t` changes no field, and a move with `x == 0` changes
  no field too: a mint of 0 does not move the lock end (L6 says "change
  nothing").
- `-1` needs `bal f > 0` before the move. A mirror that is wrong (O7) can
  see a move from a balance of 0, and this rule keeps the count correct.
- A hook needs a bound token, so a call from the zero address reverts
  before `bindToken`.
- S3 cannot unbind: `unbindToken t` needs `decided s` to differ from `t`,
  and no S3 entry changes `decided` (Q-S3-2 (a)). S6 changes it.

### 3.3 Part R: rules as types

A rule is a decidable proposition over the state before the move, the time
and the move:

```
Rule := (s : State) -> (e : Env) -> (m : Move) -> U
Dec P := Sum P (P -> Empty)
Allowed s e m := P1 s e m * ... * Pn s e m
```

`P1 ... Pn` are the rules of the program. S4 checks the kit form of
`Empty`; if the kit has none, `Dec` uses `Path Flag b flagYes` with a
witness for each side.

A program gives its rules with the `rules` form (O4). The form elaborates to
`Allowed`, to one `dec` term for each rule and to the view `canTransfer`.
The checker refuses a rule with no `dec` term (O5). So the type of a legal
move is `Sigma (m : Move) (Allowed s e m)`, and `canTransfer` is the first
bit of `Dec (Allowed s e m)`.

The rule kinds of the paste (holder caps, country rules, lock-ups):

| Rule | Proposition on `transfer f t x` | Parameters |
|---|---|---|
| `HolderCap n` | `holders (step s e m) <= n` | `n : U256` |
| `ClassCap c n` | `holdersIn (step s e m) c <= n` | `c : Class`, `n : U256` |
| `CountryIn S` | `member (cls t) S == yes` | `S`: a set of country codes (4.2) |
| `LockUp d` | `lockEnd s f <= now e` | `d : Nat` seconds; `created` sets `lockEnd t := now + d` |

A cap is a rule on the state after the move, so the decision runs `step`
first. A move to an address that already holds tokens does not change
`holders`, so a full cap still lets it pass. The lock-up clock is the kit
`now`, which lowers to TIMESTAMP (`src/evm.c:249`, Q8 (a)).

A mint and a burn are not checked by `canTransfer`. The EIP says that mint
and burn bypass the compliance rules. `created` and `destroyed` only update
the mirror.

S4 notes (2026-10-24). The kernel change is in five files:
src/front/lexer.h and src/front/lexer.c (`TOK_KW_RULES`, the keyword
`rules`), src/front/ast.h (`DECL_RULES`: the params hold S, M and T, and
the ctors hold the rule names), src/front/parser.c (`parse_rules`, which
`parse_decl` calls) and src/front/check.c (`RULES_HELPERS`,
`RULES_HELPER_TEXT`, `text_named`, `rules_prod`, `rules_dec`,
`rules_text`, `check_rules`). The checker writes the text two times (first
to get the size, then into the arena). It lexes the text with
`lex_internal`, parses it as `ORIGIN_PROGRAM` (the cofamily uses
`ORIGIN_DOMAIN`) and checks each generated declaration with
`check_generated`. The generated binders start with `.` (`.env .s .f .t
.x`), so they do not capture R, S, M or T. The surprises:

- `m->def_cap` was set, but nothing checked it. S4 adds the guard in
  `check_def_body`, the one writer of `m->defs`: a def past the cap gives
  `OOM`.
- The count `RULES_HELPERS + 2K + 4` has one spare slot, because the form
  declaration is in `decls->count` and adds no def. Thus the mutant
  `RULES_HELPERS 9u` survives (an equivalent mutant). The guard fires only
  when a count is short by more than the spare slots (the form and each
  event, which add no def).
- In guest mode, `examples/restrict.lang` and `rules-no-dec.lang` give
  `REFUSE_KIT` at `Move` (`Addr`) before the form. Thus S4 has no guest
  row for the form.
- `langc run` calls `canTransfer` as a view with no change to the runner.
- Review fixes: source names admit dot-separated components, so programs
  can use the generated decisions. Leading dots stay internal. Per-rule
  propositions and decisions are `R.rule.ri.holds` and `R.rule.ri.dec`,
  separate from helpers even when a test is named `dec`, `bit` or `both`.
  `test/fronttool.c` checks all helper-name collisions, exported decisions,
  qualified input names, the false branch and the guest boundary.

### 3.4 Part C: identity claims as ZK credentials

In ERC-3643 a wallet maps to an ONCHAINID identity. Trusted issuers sign
claims on it, and the claim topics are `uint256` values. The identity
registry answers `isVerified(address)` and `investorCountry(address)`
(`uint16`) (EIP). The claims and the country are public. restrict-lang keeps
them private:

| Name | Kind | Meaning |
|---|---|---|
| `Country` | base data | an ISO 3166-1 numeric code |
| `Class` | closed base data, computed | the classes that the rules can tell apart (4.2) |
| `cls` | `Country -> Class` | computed at compile time from the rules |
| `Ring c` | state | the credential keys of class `c` that the issuers published |
| `issue c K` | entry, issuer only | adds the credential key `K` to `Ring c` |
| `register c sig` | entry | the caller links its wallet to class `c` (4.3) |
| `clsOf` | `Map Addr U256` | the class code of each registered wallet |
| `expires` | `Map Addr Nat` | the end of each registration |
| `used` | `Map U256 Flag` | the spent key images |
| `isVerified w` | view | `clsOf w` is set and `now < expires w` |

The issuer checks the investor off chain: all the claim topics that the DAO
requires (KYC, accreditation, and so on) and the class of the country. Then
it publishes a fresh credential key `K` into `Ring c`. The ring does not
name the wallet. To register, the wallet `w` gives a bLSAG over `Ring c`.
The message is `w` and this contract. The key image is `I = x * Hp(K,
this)`. In the type the proof is `ZKProof (Sigma (k : CredKey) (InRing c k
* Owns k))`. The contract learns the class `c` and nothing more.

## 4. Readings of the design on Cubical TT

### 4.1 "State those rules as types"

The paste asks for the rules as types. The reading of 3.3 is a refinement:
a legal move is a pair of a move and a proof of `Allowed`. The proof is
never on chain. The chain needs the decision only, and `Dec` gives it. Two
laws follow:

- L1: `canTransfer s e f t x == yes` exactly when `Allowed s e (transfer f
  t x)` has a term. This holds by construction: the view is the first bit
  of the `Dec` term.
- L3: if `canTransfer` says yes, then the cap holds after the move. A cap is
  part of `Allowed`, so this also holds by construction.

The alternative is a rule as a state invariant `Inv : State -> U` only. The
compiler would then derive the move check `Inv (step s e m)`. That cannot
state a lock-up, which is a rule on the move and the time, not on the
state. The reading of 3.3 holds both kinds.

### 4.2 Country rules and the class partition

A country rule reads `member c S` for a fixed set `S`. A rule set has
finitely many such sets `S1 ... Sk`, and each rule reads the country only
through these bits. So the compiler computes `cls c := (member c S1, ...,
member c Sk)` and keeps only the vectors that occur. `Class` is that
finite set, written as a nested `Sum Unit`. Two countries with the same
class get the same answer from every rule (L2). The holder discloses the
class, not the country (Q5 (a)). An accreditation flag, when a rule reads
it, is one more bit of the vector.

Example: rules `CountryIn {840}` (US only) and `ClassCap us 2000` give two
classes, `us` and `other`. The proof shows "US" or "not US" and nothing
more.

A change of the rule set can change the classes. Then each registration of
the old classes ends (O10).

### 4.3 The credential proof

From intent-lang: the bLSAG verifier, unrolled for a ring of fixed size `n`
(H:318). New:

- The ring for each class is issuer state, not member state.
- The key image depends on this contract: `I = x * Hp(K, this)`. In
  intent-lang the key image does not depend on the poll (resolve-lang 4.3,
  a survey finding). With that key image, an observer could link the wallets
  of one credential across tokens. The per-contract key image costs one hash
  to curve for each ring slot (MODEXP 0x05 for the square root). resolve-lang
  O10 needs the same work (O8).
- One credential registers one wallet in this contract (L7). So a count of
  wallets is a count of credentials (Q6 (a)).

Limits, stated in SPEC as non-goals:

- The anonymity set is `Ring c`, at most `n` keys. A small class has a
  small set.
- An investor with two credentials from two issuers can register two
  wallets. The charter binds the issuers (O11).
- A revoked credential stays valid until the ring expires (O10).

### 4.4 The DAO vote and the UAT regime

The DAO votes on a rule set, a parameter value or an issuer. Q10 (a): each
vote is a yes or no on one proposal. For two alternatives, simple majority
is the only rule that is anonymous, neutral and positively responsive (May's
theorem, 1952), so Arrow's theorem does not apply:

- anonymous: the orbit quotient of the DAO;
- neutral: the yes and no ends swap by `sym`;
- positively responsive: majority on the opened tally.

Q10 (b): a vote on a numeric parameter, such as a cap, picks from a finite
ladder of values. Preferences over a line are single-peaked, and the median
of the peaks is strategy-proof (Black, 1948). The ballot is one-hot over the
ladder, the counts open, and the median comes from the counts.

orbit-lang `design/DESIGN.md:39` names three UAT regimes. Which regime holds
each kind of vote is O13 (read MavenRain/self-referential-dao).

The ballots are encrypted (`Enc`, one-hot), and only the tally opens. intent-lang
has not built its encrypted ballots yet (its S9). resolve-lang plans them
for its S6. restrict-lang needs them in its S6 (O9).

### 4.5 The chain fragment

From intent-lang (P 4.3), unchanged: exponential ElGamal on BN254 G1 (ecAdd
0x06, ecMul 0x07), the threshold opening with one DLEQ proof for each share,
Sigma verifiers by Fiat-Shamir (keccak), bLSAG membership, ecrecover. New:
the issuer rings, the per-contract key image (O8), the ICompliance ABI
(section 7).

## 5. Laws

| Law | Statement | How it holds |
|---|---|---|
| L1 decide | `canTransfer` says yes exactly when `Allowed` has a term | the view is the bit of `Dec` |
| L2 factor | each rule reads the country only through `cls` | the class partition (4.2) |
| L3 cap | yes from `canTransfer` gives `holders (step s e m) <= n` | part of `Allowed` |
| L4 lock | `canTransfer` says no when `now e < lockEnd s f` | part of `Allowed` |
| L5 mirror | after each hook, `bal` equals the token balances | chain rows on the test token (Q13) |
| L6 count | `step` changes `holders` only at a zero crossing; `f == t` and `x == 0` change nothing | `elim` on the cases, `refl` |
| L7 one wallet | a key image registers at most one wallet | `used` |
| L8 verified | `isVerified w` exactly when a registration of `w` is live | state rule |
| L9 only token | `transferred`, `created` and `destroyed` revert unless the caller is the bound token | state rule |
| L10 tally | `open q (tallyEnc bs) == count (map decrypt bs)` | law-only, as in intent-lang P 3.1 |
| L11 privacy | only the tally opens; `observe = |_| . decrypt` | squash path (intent-lang S5) |
| L12 DAO | the Lan unit, descent and uniqueness laws; charter ratification | ported (orbit-lang, intent-lang) |

## 6. Kernel route

S2 copies intent-lang ef5abe8 with `git archive ef5abe8 | tar -x` into the
seed. This is how intent-lang S2 ported orbit-lang and how resolve-lang S2
ports intent-lang. kitshift.py does not fit (its KEPT rule keeps the seed
files). After the copy:

- Rename `intent-lang` to `restrict-lang` in the names of the language. The
  "(orbit-lang Sn ...)" and "(intent-lang Sn ...)" comments stay as
  provenance.
- Keep Part D, Enc, Quorum, Transcript, the Sigma verifiers, the bLSAG
  ballots and ecrecover. ecrecover has no use in restrict-lang (O14).
- The gate after the port is `make -B check`: archive mtimes are stale.
  The S2 target is the intent-lang S7 counters: examples 49, check refusals
  186, kit-only refusals 22, evals 188, precompile 143 steps, emit 24, every
  regression line passed (`~/Documents/intent-lang-S7-b5-gate.log`).
- If intent-lang commits its S8 (`Env.block`) before S2 runs, S2 can port
  that commit instead. restrict-lang does not need `Env.block` (Q8 (a)).

S2 (DONE, 2026-10-24): intent-lang HEAD was still ef5abe8 (no S8 commit),
so the source is ef5abe8 (tree da87a361). The base is the S1 commit
1ce92da (tree 6f6c339d, parent d66168e). The port is `git -C intent-lang
archive ef5abe8 src domain examples test gen Makefile | tar -x`, then `git
archive ef5abe8` of SPEC.md, docs/host/README.md, docs/VALIDATION.md,
formers/FORMERS.md, formers/tcc-evm-contract.md and probe/CAPABILITY.md.
The survey (`diff -rq` of the seed and an archive of ef5abe8) found no
other doc file. The seed keeps design/, docs/PLAN.md, README.md and
LICENSE-*. docs/STATUS.md keeps the seed text and gets an S2 item with the
list of name edits. After the copy, the code is the ef5abe8 code byte for
byte (`diff -rq`). Surprises:

- The seed has two files that ef5abe8 does not have:
  `examples/inventory.lang` and `test/check/domain-name.lang`. The archive
  does not remove them, so S2 removes them (`git rm`), as intent-lang S2
  and resolve-lang S2 did. They are seed files, not ported code, so
  "nothing is removed" above still holds for the port.
- There are four name edits, the same four sites as in resolve-lang S2:
  SPEC.md lines 1, 3 and 14, and docs/host/README.md line 3. The other
  `intent-lang` words in the ported files are provenance: the comment at
  src/front/front.c:12, the S2 row at docs/host/README.md:40, and the
  evidence paths `~/Documents/intent-lang-work/...` in docs/VALIDATION.md
  (lines 315 and 373), test/secptool.c:3 and test/precompile.sh:144.
- The gate log `~/Documents/restrict-lang-S2-gate.log` is byte for byte the
  intent-lang S7 log (110 lines). No name edit is in a file that the gate
  reads.
- The S7 log comes from a serial `make -B check` with the line `EXIT 0` at
  the end. A `make -B -j 2 check` run also gives EXIT 0, but two jobs print
  the build command lines in a different sequence, so `cmp` fails. Its
  sorted lines are the sorted lines of the S7 log
  (`~/Documents/restrict-lang-S2-gate-j2.log`). A serial run is in the
  `-j 2` limit, so the byte-for-byte gate is the serial run.

## 7. The contract

One contract for each program and each token. The names and the ABI types
of the first eight rows are those of ICompliance (EIP). The kit maps `Flag`
to `bool`, `U256` to `uint256` and `Addr` to `address` (H:200).

| Entry or view | ABI | Effect |
|---|---|---|
| `bindToken` | `bindToken(address)` | DAO decision; stores the token; emits `TokenBound` |
| `unbindToken` | `unbindToken(address)` | DAO decision; emits `TokenUnbound` |
| `isTokenBound` | view `isTokenBound(address) -> bool` | |
| `getTokenBound` | view `getTokenBound() -> address` | a view with no parameter (O6) |
| `canTransfer` | view `canTransfer(address,address,uint256) -> bool` | the decision of `Allowed` (L1) |
| `transferred` | `transferred(address,address,uint256)` | caller is the token (L9); `step` |
| `created` | `created(address,uint256)` | caller is the token; `step`; sets `lockEnd` |
| `destroyed` | `destroyed(address,uint256)` | caller is the token; `step` |
| `isVerified` | view `isVerified(address) -> bool` | the identity registry view (Q3 (a)) |
| `issue` | entry | an issuer that the DAO lists adds a key to `Ring c` |
| `register` | entry | the bLSAG check (3.4); stores `clsOf`, `expires`, `used` |
| DAO entries | | charter amendment, `Params` and rule-set ratification (ported) |

Events: `TokenBound(address)`, `TokenUnbound(address)` (EIP), `Issued`,
`Registered` (the class and the key image only), `Broken` (Q9 (a): a hook
saw a move that `Allowed` refuses, for example a forced transfer).

The token points at this contract twice: as its compliance and as its
identity registry (Q3 (a)). The contract does not serve `investorCountry`:
the country is hidden (O12).

## 8. Tests

Guest files under `test/check/` and `examples/`, `langc run` scripts under
`test/run/`, and chain rows in the kit scripts:

- `rules-no-dec.lang`: a rule with no `dec` term gives `TYPE_MISMATCH` (O5).
- `rules-cap.lang`: L3 and L6 by `refl` on small states: a full cap refuses
  a new holder and lets a move to a holder pass; a partial move keeps the
  count; a full move lowers it; `f == t` and `x == 0` change nothing.
- `rules-lock.lang`: L4 at `now == lockEnd - 1` (no) and `now == lockEnd`
  (yes).
- `rules-class.lang`: the class partition of the 4.2 example; two countries
  of one class get the same answer (L2).
- Run scripts with the `now` column: a second `register` with the same key
  image is refused; an expired registration gives `isVerified` no; a hook
  from an address that is not the token reverts; a forced move emits
  `Broken`.
- Ring rows: one credential in two contracts gives two different key images
  (O8).
- Chain rows: the test token calls `isVerified`, `canTransfer`, then the
  hook, in the order of the EIP example; `bal` equals the token balances
  after each row (L5).

## 9. Slices

| Slice | Content | Status |
|---|---|---|
| S0 | generate from lang-template (tcc-evm-contract); DESIGN verbatim; this plan; README; kit gate | DONE |
| S1 | USER rules Q1-Q14; this plan records the rulings | DONE |
| S2 | port intent-lang ef5abe8 (section 6); gate = the intent-lang S7 counters | DONE: `make -B check` EXIT 0 with the intent-lang S7 counters: 49 examples, 0 failed; 19 parse, 186 check and 22 kit-only refusals; 188 evals, 2 proves; contracts 2 written and 5 refused; rings 6 built and 2 refused; 28 guest and 14 host differential rows; 5 runs, 10 run refusals; 8 asmtool; 3 builds, 16 lower refusals, 33 build checks; 20 dispatch; 43 evm steps; 14 precompile rows and 143 steps; 13 mock rows; 15 diff rows; 24 emit regressions; the 13 "regressions: passed" lines; 0 failures. The log is byte for byte the intent-lang S7 log (section 6) |
| S3 | Part T: `Move`, the mirror state, `step`, the hooks with L9, the binding; L6 | DONE (2026-10-24): `examples/mirror.lang` (16 L6 paths by `refl`) and `test/run/mirror.script` (17 rows, L9); the kernel does not change. `make -B check` EXIT 0. Two counters change from the S2 log: examples 49 -> 50 (`mirror.lang` in `examples/kit.txt`) and runs 5 -> 6 (`test/run/mirror.script`); all other lines are the S2 lines; 0 failures. Mutants: 7 (L6 x5, L9 x2), 7 KILLED; the gate after the restore is byte for byte the S3 gate log |
| S4 | Part R: the `rules` form (O4), `Dec`, `Allowed`, `canTransfer`; the four rule kinds; L1, L3, L4; the rows of section 8 | DONE (2026-10-24): the kit form `rules` in five src/front files (section 3.3, S4 notes); `examples/restrict.lang` (`mirror.lang` with Part R: four rule tests, one form, `Broken`; 23 more `refl` paths: L1 x5, rules-cap x13, rules-lock x5), `test/check/rules-no-dec.lang` (`TYPE_MISMATCH`, O5) and `test/run/restrict.script` (14 rows). `make -B check` EXIT 0. Three counters change from the S3 log: examples 50 -> 51 (`restrict.lang` in `examples/kit.txt`), check refusals 186 -> 187 (`rules-no-dec.lang`) and runs 6 -> 7 (`test/run/restrict.script`); all other lines are the S3 lines; 0 failures. Mutants: 7 (L1, L3 x2, L4, O5, `Broken`, `RULES_HELPERS 9u`), 6 KILLED, 1 SURVIVED (an equivalent mutant, section 3.3 S4 notes); the gate after the restore is byte for byte the S4 gate log |
| S5 | Part C: the class partition (4.2), the issuer rings, `register` with the per-contract key image (O8), `isVerified`, expiry; L2, L7, L8 | NEXT |
| S6 | the DAO over the rules: `Params` for each parameter, the issuer list, rule-set amendment, encrypted ballots (O9) | |
| S7 | the contract writer: the ABI of section 7, the events, chain rows on the test token (Q13) | |
| S8 | mutants, SPEC, VALIDATION, close | |

## 10. Open items

Each item is RULED (S1, 2026-10-24) or kept as the builder call.

- O1 name: restrict-lang, from the title of the paste. Builder call. Kept.
- O2 target: EVM by hosts/tcc-evm-contract. ERC-3643 is an EVM standard.
  Builder call. Kept.
- O3 kernel: port intent-lang ef5abe8. RULED: Q1 (a).
- O4 the `rules` form: a top-level form that elaborates to definitions, as
  the cofamily form does in intent-lang and the `market` form does in
  resolve-lang (text elaboration). The alternative is a Sigma over the
  universe; it loses the rule names, and the contract needs them for the
  `Params` of each rule. Kept.
- O5 decidability: a rule must have a `dec` term. The atoms are U256 and Nat
  comparisons, Map reads and `member` over a fixed set. A rule that
  quantifies over all addresses has no `dec` term. Default refusal:
  `TYPE_MISMATCH`, no dedicated code. Kept: `TYPE_MISMATCH`.
- O6 the ABI names: the kit must accept the exact names `canTransfer`,
  `isTokenBound` and so on, and a view with no parameter
  (`getTokenBound()`). S7 checks the selectors against the EIP signatures.
  If the kit refuses either one, S7 changes the kit. Kept: S7 work.
- O7 the mirror is correct only if the token calls a hook for each balance
  change: forced transfers and recovery too. The EIP does not say whether a
  forced transfer calls `transferred`. The chain rows test the test token
  only (Q13). The freeze of tokens is a token rule, not a compliance rule.
  Kept: Q13 (a) tests the test token only.
- O8 the per-contract key image needs a hash to curve on chain (MODEXP
  0x05). resolve-lang O10 needs the same work. The first of the two to build
  it gives the form; the other ports it. Kept: Q4 (a) needs the key image.
  The hash to curve is S5 work.
- O9 encrypted ballots: intent-lang S9, resolve-lang S6 and restrict-lang S6
  need the same form. One builds it; the others port it. Kept.
- O10 rings expire. A registration ends with its ring, and a holder
  registers again with a new ring. Revocation is a new ring without the key.
  A change of the rule set that changes the classes ends every registration
  of the old classes. A wallet that holds tokens and loses its registration
  keeps its tokens. It cannot receive more, because `isVerified` says no.
  Kept.
- O11 two credentials from two issuers give two wallets. A per-investor cap
  is a per-credential cap. The charter binds each issuer to issue one
  credential for each investor and class. Kept.
- O12 `investorCountry(address)` is not served: the country is hidden (Q5
  (a)). A token or a tool that calls it fails. Kept: Q5 (a).
- O13 the UAT regime of each vote kind (4.4). Kept: open until S6.
- O14 ecrecover comes with the port and has no use. Kept: S2 keeps it.
- O15 the guest poll id is fixed to 0 (H:310). Each DAO proposal needs a
  poll id: a change of the signature. Kept: S6 work.
- O16 the transfer agent bullet: the token stays the record of ownership.
  The compliance contract keeps a mirror only (3.2). Kept.

## 11. Questions for the USER (S1)

Each question has a recommendation (a). All fourteen are RULED (S1,
2026-10-24; the quote is in section 1).

- Q1 kernel route. (a) Port intent-lang ef5abe8: R1 is already enforced.
  (b) Port orbit-lang 2162fb2 and narrow it to R1 again. RULED: (a).
- Q2 "govern all contracts". (a) Every contract that restrict-lang writes:
  the DAO is part of the contract and owns each parameter, the issuer list,
  the binding and the rule set. The owner and agent roles of the token stay
  with the issuer. (b) Also the token: a new kit `Out` form `call` lets the
  DAO act as the token owner and agent (pause, freeze, forced transfer).
  RULED: (a).
- Q3 identity registry. (a) The contract also serves `isVerified(address)`,
  and the token uses it as its identity registry. (b) Compliance only. A
  standard identity registry with public ONCHAINID claims stays, and the ZK
  credentials gate `canTransfer` only. RULED: (a).
- Q4 the credential proof. (a) bLSAG over the issuer ring of each class,
  with a key image for each contract (4.3): the port has it, the gas grows
  with the ring size. (b) Merkle membership with a Groth16 verifier on the
  pairing precompile 0x08: a new proof form and an off-chain circuit, but
  the gas does not grow with the set. RULED: (a).
- Q5 disclosure. (a) The class only: the partition that the rules read
  (4.2). (b) The country code, so that `investorCountry` can be served.
  RULED: (a).
- Q6 the unit of a holder. (a) A wallet; one credential registers one
  wallet in each contract. (b) A credential with many wallets: each wallet
  registers under the same key image, and the count is per credential. The
  chain then sees which wallets belong together. RULED: (a).
- Q7 lock-ups. (a) One lock end for each wallet, set by `created` to `now +
  d`; a later mint moves it to the later time; a transfer in does not lock.
  (b) A lock end for each lot: a transfer can move only the unlocked units.
  This needs a lot ledger in the state. RULED: (a).
- Q8 the clock. (a) `now`, which lowers to TIMESTAMP (seconds): holding
  periods are calendar time. (b) Blocks: `Env.block`, NUMBER, as intent-lang
  O17. RULED: (a).
- Q9 a move that the rules refuse. (a) The hooks never revert for a rule.
  The token agent can force a move (the EIP lets a forced transfer bypass
  the rules); the hook updates the mirror and emits `Broken`. (b) The hooks
  revert, so a forced move that breaks a rule fails. RULED: (a).
- Q10 the DAO vote. (a) Yes or no on one proposal (May, 4.4). (b) Also a
  one-hot ballot over a ladder of values with the median for numeric
  parameters (Black, 4.4). RULED: (a).
- Q11 country rules read. (a) The receiver only. (b) The sender and the
  receiver. RULED: (a).
- Q12 holder caps. (a) A total cap and a cap for each class. (b) A total cap
  only. RULED: (a).
- Q13 the token of the chain rows. (a) A test token in the kit test style
  that calls `isVerified`, `canTransfer` and the hooks in the order of the
  EIP example. (b) The bytecode of the reference T-REX token, pinned.
  RULED: (a).
- Q14 the DAO members. (a) The members that the charter lists (ported): for
  example the issuer, the transfer agent and the holder delegates. (b) The
  registered holders: one credential, one vote. RULED: (a).

## 12. Questions of S3

Each one is a builder call (a); the USER can rule otherwise. None changes
the build of S3 (STEP 3 of the S3 prompt), so S3 went on.

- Q-S3-1 the class key of `holdersIn` before Part C. (a) A helper
  `clsCode : State -> Addr -> U256` gives class 0 for each address; `step`
  keys `holdersIn` by it. S5 changes only its body to `mapGet (clsOf s) a`.
  (b) S3 leaves `holdersIn` out; S5 adds it.
- Q-S3-2 the binding guard before the S6 DAO forms. (a) The binding applies
  a DAO decision: a state slot `decided : Addr` holds the token that the
  DAO decided to bind (S3: `init` sets it to the test token
  0x00000000000000000000000000000000000000ee; S6 makes it the enacted
  `Params` value). `bindToken t` binds when no token is bound, t is not the
  zero address and t == decided s; any caller can apply the decision, so
  there is no key. `unbindToken t` unbinds when t is the bound token and
  decided s is not t. They emit `TokenBound` and `TokenUnbound`. (b) A
  placeholder owner key `dao : Addr` until S6: this adds a key, which
  section 3.1 forbids. (c) Move the two entries to S6 and fix the token in
  `init`.
- Q-S3-3 the lock length before `Params`. (a) A constant `def lockD : Nat`
  (86400) in the example; `created` sets `lockEnd t` to the later of
  `lockEnd t` and `now + lockD` (Q7 (a)); S6 makes it a `Params` value.
  (b) No lock end in S3; S4 adds it with LockUp.
- Q-S3-4 the form of `Move`. A program cannot declare a family
  (SPEC.md line 36, `REFUSE_DATA`), and no family of domain/domain.lang has
  an `Addr` or a `U256` field. (a) A Sum alias in the program: `def Move :
  Type 0 := Sum (Prod Addr (Prod Addr U256)) (Sum (Prod Addr U256) (Prod
  Addr U256))`, with the helpers `transfer`, `mint` and `burn`, and `step`
  takes it apart with `either`. intent-lang S8 (c6636f1) writes its records
  as Prod aliases for the same cause. (b) A family `Move` in
  domain/domain.lang: this changes the ported kernel. It is not a USER
  question for S3, because the content of the move does not change.

The S3 survey (2026-10-24) checked the three proposals before the build:

- Q-S3-1: the kernel has no class data before S5, so a constant class code
  is the only key. A helper with a State argument checks (examples/contract.lang
  `checkpoint`).
- Q-S3-2: examples/dao.lang and examples/dao3.lang have no state and no
  entry. The ported kernel has no DAO decision form on the chain, so the
  binding reads a `decided` slot until S6.
- Q-S3-3: `Params` is S6 work. `now` is a Nat (src/front/contract.c:8,
  `makeEnv (now : Nat) (caller : Addr)`), so `natAdd (now e) lockD` checks.
- An entry reverts with `none`, and a guard is `flagIf c (some ...) none`
  (examples/zkcast.lang:19-24). A view with no parameter checks
  (examples/contract.lang `balance`), so `getTokenBound` is a view now; S7
  checks its selector (O6).
- `u256Sub` does not go below 0 (src/lower.c:400 maps it to IR_OP_SUB,
  src/evm.c:187 emits `sub_sat`), and `u256Add` traps on overflow. So a
  mirror that is wrong (O7) cannot make a hook revert by a subtraction.
- The kit has `u256Le` and `u256Eq` but no `u256Lt`
  (src/front/check.c:191-194).

No question changes the build of S3. The USER can rule each one later.

## 13. Questions of S4

Each one is a builder call (a); the USER can rule otherwise. None changes
the content of the build of S4 (STEP 3 of the S4 prompt). Q-S4-7 changes
only how the rows of section 8 are put into files.

The S4 survey (2026-10-24) checked these facts with `build/langc --kit
check` on the probes in `~/Documents/restrict-lang-work/S4-probes/` (p1
prints ok; p2 gives `TYPE_MISMATCH`):

- `Flag` is a kit base type (src/front/check.c:138, `RULE_TYPE0`), not a
  family. `elim` does not take a `Flag`, and `flagIf` is not dependent. So
  no term decides `Path Flag b flagYes` for a variable `b`. The fallback of
  section 3.3 fails for the same cause.
- `Sum Unit Unit` has a dependent `elim`, and a motive into `Type 0` checks.
  `transp` over that motive gives `Path B (inr u) (inl unit) -> Empty`
  (p1 `noB`). So `Dec P := Sum P (P -> Empty)` is the form of section 3.3.
  Each rule test is a `Flag`, and the form lifts it to `B := Sum Unit Unit`
  with `flagIf b (inl unit) (inr unit)` (p1 `toB`, `decB`).
- The kit `Empty` is `family Empty := emptyLoop (emptyOf : Empty)`
  (domain/domain.lang:75). `P -> Empty` and `Sum P (P -> Empty)` check.
- The `Dec` of a product checks with two `either` (p1 `decAnd`). The bit of
  a closed `Dec` term normalizes, so `refl` checks it (p1 `yesBit`, `noBit`,
  `andBit`).
- A def of type `Addr -> Flag` whose body is a proposition over all
  addresses gives `TYPE_MISMATCH` (p2). This is the O5 code.
- The language has no import form (src/front/parser.c has none).
- The cofamily form is the model of O4. `check_cofamily`
  (src/front/check.c:4479) writes text from the names of the declaration,
  lexes it with `.` as a name character (`lex_internal`), parses it
  (`parse_source`) and checks each declaration (`check_generated`, :4447).
  `check_program` (:4555) counts the extra definitions before the check.
- `examples/mirror.lang:31` has a def `dec` (the U256 decrement), so the
  generated names have the form name as a prefix.
- A refusal row is a line `FILE CODE` of test/check/expect.txt. A file that
  checks in kit mode is a line of test/check/kit.txt or examples/kit.txt.
  `langc check` prints ok for each file of examples/.

The questions:

- Q-S4-1 the `rules` form. (a) `rules R S M T := r1 | ... | rk`. `R` is the
  name of the form. `S` and `M` are the names of the state type and the move
  type. `T` is the transfer helper (`Addr -> Addr -> U256 -> M`). Each `ri`
  is a program def of type `S -> Env -> M -> Flag`: the test of the rule.
  The form takes names only, so it elaborates to text as `check_cofamily`
  does, and each generated declaration is checked as a program def, in this
  order:

  | Name | Text |
  |---|---|
  | `R.B`, `R.yes`, `R.lift`, `R.Holds` | `Sum Unit Unit`; `inl unit`; `fun (b : Flag) => flagIf b (inl unit) (inr unit)`; `fun (x : R.B) => Path R.B x R.yes` |
  | `R.Dec` | `fun (P : Type 0) => Sum P (P -> Empty)` |
  | `R.Code`, `R.no` | the motive into `Type 0` and the `transp` term (p1 `Code`, `noB`) |
  | `R.decide` | `(x : R.B) -> R.Dec (R.Holds x)` by `elim` (p1 `decB`) |
  | `R.both`, `R.bitOf` | p1 `decAnd` and `bitOf` |
  | `R.rule.ri.holds` | `S -> Env -> M -> Type 0 := fun (s : S) (e : Env) (m : M) => R.Holds (R.lift (ri s e m))` |
  | `R.rule.ri.dec` | `(s : S) -> (e : Env) -> (m : M) -> R.Dec (R.rule.ri.holds s e m) := fun ... => R.decide (R.lift (ri s e m))` |
  | `R` | `S -> Env -> M -> Type 0`: the right-nested `Prod` of the `R.rule.ri.holds s e m` (k = 1: `R.rule.r1.holds s e m`) |
  | `R.dec` | `(s : S) -> (e : Env) -> (m : M) -> R.Dec (R s e m)` by `R.both`, right nested |
  | `R.bit` | `S -> Env -> M -> Flag := fun ... => R.bitOf (R s e m) (R.dec s e m)` |
  | `canTransfer` | `(env : Env) -> (s : S) -> (f t : Addr) -> (x : U256) -> Flag := fun ... => R.bit s env (T f t x)` |

  The view has the EIP name and ABI (section 7). L1 holds by construction:
  `canTransfer` is the first bit of `R.dec`. A rule `ri` that is not a
  `Flag` test makes `R.rule.ri.holds` fail with `TYPE_MISMATCH` (O5, p2). The form is
  a kit form: in guest mode it gives `REFUSE_KIT` (`kit_refused`), as the
  state form does. (b) The form takes terms (`ri fun (s : S) ... => ...`,
  or `ri : P by d` with a `dec` term `d`). Then the checker must put parsed
  terms into the generated text, and the kernel has no printer of terms.
  This is later work.
- Q-S4-2 `CountryIn S` before Part C. (a) The test reads `clsCode s t`
  (class 0 for each address, Q-S3-1 (a)) and a fixed set `inSet : U256 ->
  Flag` (S4: class 0 only). S5 changes only the bodies of `clsCode` and the
  set. (b) S4 leaves `CountryIn` to S5.
- Q-S4-3 `ClassCap c n`. (a) `u256Le (mapGet (holdersIn (step s e m)) capC)
  capCN`, with `holdersIn` keyed by `clsCode` (Q-S3-1 (a)).
- Q-S4-4 the parameters `n`, `c`, `S` and `d`. (a) Constant defs in the
  example (`capN`, `capC`, `capCN`, `inSet`; `lockD` stays) until the
  `Params` of S6, as `lockD` in S3.
- Q-S4-5 the sender of a move. `LockUp` reads `lockEnd s f`, and a mint has
  no `f`. (a) A helper `moveFrom : Move -> Addr`: a mint gives `noAddr`,
  whose lock end is 0. `canTransfer` checks transfers only (the EIP bypass).
- Q-S4-6 `Broken` (Q9 (a)). (a) S4 adds `event Broken (brokenFrom : Addr)
  (brokenTo : Addr) (brokenAmount : U256)`. `transferred` emits it when
  `canTransfer env s f t x` is no on the state before the move, and still
  runs `step`. `created` and `destroyed` do not emit it (the EIP bypass).
  (b) S7 adds it with the other events.
- Q-S4-7 the files. A program cannot import a program. (a)
  `examples/restrict.lang` is a copy of `examples/mirror.lang` (Part T) with
  Part R, and S5 to S7 extend it. It holds the section 8 rows of
  `rules-cap` (L1, L3) and of `rules-lock` (L4) as two groups of `refl`
  laws. `test/check/rules-no-dec.lang` gives `TYPE_MISMATCH`.
  `test/run/restrict.script` has the `now` column. `mirror.lang` and
  `mirror.script` do not change, so the S3 counters stay. (b) Two more
  copies of Part T, in `examples/rules-cap.lang` and
  `examples/rules-lock.lang`, as section 8 names them.

The counters that S4 can change: examples 50 -> 51 (`restrict.lang`),
check refusals 186 -> 187 or more (`rules-no-dec.lang` and the refusal rows
of the form), runs 6 -> 7 (`restrict.script`), and the fronttool lines if a
host C test of the parser is necessary.
