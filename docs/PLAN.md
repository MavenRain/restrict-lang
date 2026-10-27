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

USER rulings (S6, 2026-10-25), verbatim:

> Rulings: Take all recommendations. Follow
> ~/Documents/restrict-lang-work/S6-build-PROMPT.md. After, if necessary,
> give next session prompt.

So each question of section 15 takes its recommendation (a):

- Q-S6-1 (a): S6 s2 ports intent-lang 3df9d96 (its S9) as is: the tally
  and ballot examples, `test/ballottool.c`, `tally-leak.lang`, the eval
  rows, the ballot precompile steps and the Makefile rows. No src change.
- Q-S6-2 (a): four parameters, each one state word: `pCapN`, `pCapCN`
  (U256), `pLockD` and `pRegD` (Nat). `init` holds the S4 and S5 values.
- Q-S6-3 (a): the DAO votes yes or no on one proposal. A fail or a tie
  keeps the old value.
- Q-S6-4 (a): the issuer list is the state map `issuers : Map Addr Flag`.
- Q-S6-5 (a): an amendment ratifies a rule-set id in the `Charter`, and
  the class pass set of the country rule becomes a state map.
- Q-S6-6 (a): each vote kind is Arrow-Debreu. Guest `refl` rows count one
  self-constituting outcome for the yes or no menu.
- Q-S6-7 (a): the ballot ring signs in the context word hash(selfWord,
  pid) through `zkVerifyAt`, and the ballot ctx uses pid in place of poll 0.
- Q-S6-8 (a): S6 s2 builds the port, the `Params` words, the issuer map,
  the amendment law, the setters and the regime rows. The entries
  `propose`, `ballot`, `openTally` and `enact` are S7.

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

S6 notes (Q-S6-1..8 (a), section 15):

- Q-S6-1 (a): S6 ports intent-lang 3df9d96 (its S9) as is:
  `examples/tally.lang` (the guest law of the encrypted tally),
  `examples/ballot.lang` (the kit ballot views), `test/ballottool.c`,
  `test/check/tally-leak.lang` (`REFUSE_LAW`), 15 eval rows (tally 6, ballot
  9), 9 precompile steps and the Makefile rows of `ballottool`. `Choice`
  stays yes or no. The S8 rows of intent-lang are not ported.
- Q-S6-7 (a): the ballot ring signs in the context word `pctx =
  hash(selfWord, pid)` through `zkVerifyAt` (`pid` is 1u, `self` is
  0x..c0). The guest `zkVerify` keeps poll 0. `test/ballottool.c` signs
  with `blsag_sign_at` and has a new silent row "ballot in a second
  proposal": a ballot of pid 1 does not verify for pid 2 (the ctx gives
  `SIG_BAD_SLOT`, and the context word gives `BLSAG_REJECT`). 38 words
  change in `examples/ballot.lang` and in `test/precompile.sh`: the key
  images, the context words and the slot and sum proof words. The
  ciphertexts and the ballot digest do not change. The new words are in
  ~/Documents/restrict-lang-work/S6-ballot-words.txt (`build/ballottool
  words`).
- `examples/charter.lang` (guest mode, Q-S6-5 (a)) has the slots of
  `examples/dao.lang`, but `act` swaps the two members. Thus the yes or no
  rule `yn` (`ynComm`: it is commutative) gives a constitution `passCon`.
  The charter law: `RuleSet` (`rs0` is the S4 rule set, `rs1` is the S6
  rule set), `ruleOf`, and `active : Charter -> RuleSet`, the fold of the
  history to the active id. Rows: `activeGenesis`, `activeOne`,
  `activeTwice` and `activeBack`; `passYes`, `passTie` (a tie keeps the old
  value) and `passNo`. `examples/dao.lang` does not change, because
  writertool compiles it.
- Q-S6-8 (a): the entries `propose`, `ballot`, `openTally` and `enact`, and
  the encrypted tally in the state, are S7 (the contract writer).
- Q-S7-24 (a): the `openTally` is the open of T0 in the entry `enact` (two
  DLEQ shares of the quorum {1, 2}); it has no entry of its own.
- S7 s4 (Q-S7-15 (a)): the restrictkit state has the last field `dao :
  Addr`, and init sets it to `daoAddr` (0x..da). `withGov` writes the 7
  governance fields. `fromDao s env` is `addrEq (caller env) (dao s)`. The
  setters `setCapN`, `setCapCN`, `setLockD`, `setRegD`, `setIssuer (a :
  Addr) (f : Flag)`, `setPass (k : U256) (f : Flag)` and `setDecided (t :
  Addr)` give `none` (a revert) when the caller is not the DAO. `setLockD`
  and `setRegD` take a U256 word through `toNat`. Rows: 2 for each setter
  (the DAO, another caller), `setIssuerOff` (`flagNo`: a setter that
  ignores `f` fails it) and `setKeepsDao`. Selectors: setCapN 0x3b76bd56,
  setCapCN 0xd3ca9b61, setLockD 0xc52db2d3, setRegD 0xc06225ec,
  setIssuer(address,bool) 0x495289be, setPass(uint256,bool) 0xcb18f9fb,
  setDecided 0xcbdfca26.

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
  and no S3 entry changes `decided` (Q-S3-2 (a)). S6 has no setter for
  it (Q-S6-8 (a)): the S7 entry `enact` changes it.
- S7 s4, the test token (Q13): the asmtool mode `token` writes a token at
  0x..ee that calls restrictkit (the compliance contract, address
  0x7265636569766572). transfer(address,uint256) (a9059cbb) reverts when
  the amount is more than the balance of the sender, calls isVerified(to)
  and canTransfer(from, to, x) as views (a failed call or a word 0
  reverts), moves the balance, calls transferred(from, to, x) and returns
  the word 1. mint(address,uint256) (40c10f19) credits the balance and
  calls created(to, x). balanceOf(address) (70a08231) reads the balance.
  There is no event. The runtime is 366 bytes. CHOICE: the 15 token rows
  are in `test/restrict.sh`, not in a new `make check` step, because they
  need the registration of dave (the only verified address) and the state
  of the setter rows.

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

S6 notes (Q-S6-2 (a), Q-S6-5 (a)):

- The rule tests read the Part G words of the state, not constants:
  `holderCap` reads `pCapN s`, `classCap` reads `pCapCN s`, `stepM` reads
  `pLockD s`, and the country rule reads the class pass set through `inSet
  : State -> U256 -> Flag` (`mapGet (passCls s) k`; `countryIn`, `l2Rule`
  and `l2S1Rule` pass the state). The defs `capN`, `capCN` and `lockD` are
  deleted. `capC` stays, because it is a class code. `init` holds the S4
  values (2u, 3u, 86400 s and the pass of class 0), so the S4 rows do not
  change.
- The rules form does not change (Q-S6-5 (a)). An amendment changes the
  Part G words. A new rule kind is a new contract.
- `withGov` writes the six Part G words. The setters `setCapN`,
  `setCapCN`, `setLockD` and `setRegD` (`setParam`, one for each word),
  `setIssuer` and `setPass` change one word each.
- Rows: `gCapN`, `gCapCN` and `gLockD`, each with its `Keeps` row (the
  setter changes no other word); `capRaised` (a higher cap flips
  `capNewHolderView`), `capLowered`, `classCapRaised` and `lockNew`;
  `passOpen`, `passOpenView` and `passClosed`.

S7 notes (Q-S7-2 (a)):

- The rules form writes `R.bit` with the new helper `rules_bit`
  (src/front/check.c), the `both` of the rule bits. For three rules it is
  `flagIf (r1 .s .e .m) (flagIf (r2 .s .e .m) (r3 .s .e .m) flagNo)
  flagNo`. Before S7, `R.bit` was `R.bitOf (R ..) (R.dec ..)`, an `either`
  over the `Dec`, and the kit build refused it (p1c). `R.bitOf` stays a
  helper, so the def count `RULES_HELPERS + 2K + 4` does not change.
- Three L1 rows in `examples/restrict.lang` tie the bit to the `Dec`:
  `bitDecYes`, `bitDecNo` and `bitDecNoCap` are `Path Flag (allowed.bit s
  e m) (allowed.bitOf (allowed s e m) (allowed.dec s e m)) := refl`.
- `langc --kit build examples/restrict.lang` now refuses `canTransfer: K4c
  does not lower mapGet at a word position`, not `either`. The file reads
  its state maps with the plain `mapGet`, and K4c lowers only `kmapGet` on
  a map field of the state (as `examples/daokit.lang` does). The kit maps
  are the s3 work of `examples/restrictkit.lang` (Q-S7-1 (a)), not a
  lowering change.

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

S5 notes (Q-S5-1..7 (a), section 14):

- The kit ops `zkHpAt`, `zkSignAt` and `zkVerifyAt` give `I = x * zkHpAt K
  w`, with the contract word `w = addrToU256 self` (a constant until S7).
  The wallet word `m` is the caller.
- `cls` is written by hand: S1 = {840} gives class 1, and the other
  countries give class 0. The S5 country rule lets class 0 pass (an offer to
  holders outside S1 only), so the S4 rows stay: an address that did not
  register has class 0. A `CountryIn {840}` rule gives the same two classes
  and lets class 1 pass. The computation of `cls` from the rules form is a
  new open item (O17).
- Each ring has two slots (`ringX`, `ringY`, key `c + c + i`). `issue`
  reverts for a slot `i > 1`, because that key is a slot of class `c + 1`.
  An empty slot is the point at infinity `(0, 0)`, which the verifier
  accepts.
- `regOk` (the checks of `register`) takes the signature as a list, so the
  `refl` rows build it with `zkSignAt`. A `langc --kit eval` of `sigD` and
  `sigE` shows that their last two words are the key image `img0`.

S6 notes (Q-S6-2 (a), Q-S6-4 (a)):

- The issuer list is the state map `issuers : Map Addr Flag`. `issue`
  reads `mapGet (issuers s) (caller env)`. `init` holds the S5 issuer
  `issuer0` (0x..e1). The def `issuer` is deleted.
- `regSet` reads the registration length `pRegD s`. The def `regD` is
  deleted.
- Rows: `gRegD` and `gRegDKeeps`; `r3` with `regNewEnd`, `regNewLive` and
  `regNewGone` (a new length gives a new end); `issueRemoved` (a removed
  issuer cannot issue), `issueAdded` and `issueKeysStay` (O10: the ring
  keys stay when their issuer goes).

S7 notes (Q-S7-6 (a)):

- `self` is now an `Env` field, and a def cannot have the name of a
  domain field (rule R4). So the constant `def self : Addr := 0x..c0` is
  now `def selfAddr` in `examples/restrict.lang` and
  `examples/ballot.lang`, and `selfWord` is `addrToU256 selfAddr`. The
  words do not change. In s3, `examples/restrictkit.lang` gives `selfWord
  := addrToU256 (self env)`.
- Each `makeEnv` gets `selfAddr` as its fourth argument (16 sites in
  `restrict.lang` and 2 in `mirror.lang`, which gets the same def). The
  row `selfEnvIs : Path U256 (addrToU256 (self e0)) selfWord := refl` ties
  the Env field to the constant.

S7 s3 notes (Q-S7-12 (a), Q-S7-13 (a), Q-S7-14 (e1)):

- `examples/restrictkit.lang` (new, in `examples/kit.txt`) is
  the kit form of the rules. `selfWord := addrToU256 (self env)`.
- `hpAt k w c` is yes when the x word of H_p (k, w) is the hash of the
  counter c. `hpOk k w` is yes when a counter below K = 8 gives it.
- `issue (c i kx ky hc : U256)` checks `u256Le i 1u`, `u256Le hc 7u` and
  `hpAt (pair kx ky) (selfWord env) hc`. Each issued point has an H_p
  counter below K. `register` also checks the bound for an empty slot
  at the current `selfWord`, so accepted registrations use the same H_p
  in closed eval and on the chain (Q-S7-13 (a)).
- The test keys at the chain word 0x7265636569766572 (Q-S7-12 (a)): zkKey
  13 (counter 0), zkKey 2 (counter 5), zkKey 18 (counter 7), the empty
  slot (0, 0) (counter 7), and zkKey 1 (counter 11, no point below K).
- Rows after `hpOkR`: the Path rows hpC0Is, hpC1Is, hpC2Is, hpCZIs,
  hpCRIs, hpOkRNo, and the law rows hpAtC0, hpAtC1, hpAtC2, hpAtC1Below,
  hpOkK0, hpOkK2. The rows issueBadCounter and issueNoPoint give `none`.
- When no counter below K gives a point, eval gives no (the issue row is
  `none`) and the H_p loop on the chain traps. Both make `issue` fail.

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
each kind of vote is O13 (read MavenRain/self-referential-dao). S6 (Q-S6-6
(a)): each vote kind is Arrow-Debreu (one self-constituting outcome). The
yes or no vote has one outcome, because a tie keeps the old value.
`examples/charter.lang` counts the outcomes of the yes or no menu with
`isFix`, `bumpR` and `regimeOf` (the form of `examples/regimes.lang`):
the rows `ynYes`, `ynTie` and `ynNo` give AD, and the contrast row
`echoTie` gives SI.

The ballots are encrypted (`Enc`, one-hot), and only the tally opens. S6 ports
the encrypted ballots of intent-lang S9 (Q-S6-1 (a), O9). Each proposal
has its own context word (Q-S6-7 (a), O15).

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

S7 s2 (DONE, 2026-10-25) ports intent-lang S8 (`ef5abe8..c6636f1`) and S10
(`3df9d96..79e1898`) by path. S6 had ported S9 (3df9d96). The port has no
SPEC, docs, PLAN, `intent.lang`, `intentsig.lang`, intent check files or
S8 eval rows, and no `test/lower/env-block.lang` (S8 adds it and S10
removes it). S7 notes:

- `test/ballottool.c` hunk 2 (the header) went in by hand on the S6
  header. The `dao` mode signed with `blsag_sign_at` at w = hash(self,
  pid) (S6, Q-S6-7 (a)), but `examples/daokit.lang` verifies with
  `zkVerify` (no context word), so `dao chain` gave 26 failures. The fix
  is in `test/ballottool.c` only: the helper `ballot_sign` calls
  `blsag_sign` when w is NULL, and `dao` casts its three ballots with poll
  0 and w NULL, as intent-lang S10 does. The S6 ballots do not change. The
  DAO entries of restrict-lang (s4) keep the S6 context.
- restrict-lang sites: `examples/kit.txt` gets `blocks.lang` and
  `daokit.lang`; `makeEnv N X` is `makeEnv N Nu X` in `mirror.lang` and
  `restrict.lang`; the call rows of `test/run/mirror.script` and
  `test/run/restrict.script` get the BLOCK column; the `rules_regressions`
  prelude in `test/fronttool.c` gets `(block : U256)`.
- The kit op `toNat` (Q-S7-4 (a)) has the form of `toU256`: `OP_TO_NAT`
  (core.h), the check row with `RULE_U256_2`, the eval `to_nat`
  (EVAL_OVERFLOW when limb 1, 2 or 3 is not 0), and `lower_to_nat`: an IF
  on `LE(x, 2^64 - 1)` with an empty body and a TRAP in its `otherwise`
  arm, then the value x. `evm.c` accepts the empty IF body (a kit file
  with a U256 entry builds at 128 runtime bytes). The lowertool rows
  `to-nat-symbolic` and `to-nat-static-trap` check the form. The chain
  rows of the four USER values are s4 work (the chain token). The mutants
  of the IF (an arm swap, LE to LT) need those chain rows.
- `self` (Q-S7-6 (a)) has the resolve-lang S7 form without its `chain`
  field: the prelude `makeEnv (now : Nat) (block : U256) (caller : Addr)
  (self : Addr)`, `IR_ENV_SELF`, ADDRESS (0x30) in `evm.c`, and the
  `self` name in `lower.c`. `langc run` takes `self` from the script line
  `env SELF` (one time, before the first call; with no line, `self` is
  0x0), and `make_env` in `check.c` copies it. `test/evm.sh` runs the
  chain at the `test/evmchain.sh` receiver
  (0x..7265636569766572), the address of `examples/selfenv.lang` and
  `test/run/selfenv.script`.
- `toNat` is a core name now, so `examples/circle.lang` renames its `def
  toNat : S1 -> Nat` to `s1ToNat` (REFUSE_NAME, rule R4). intent-lang and
  resolve-lang keep the name, because they have no core `toNat`.
- The counter base is the s1 step0 log (`restrict-lang-S7-step0-gate.log`,
  115 lines). A second session wrote over the s2 step0 log (116 lines),
  so it is not a base.

S7 s3 (DONE, 2026-10-26) notes (Q-S7-10 to Q-S7-14):

- The open zkHpAt (session 6): `zk_hp_term` in `eval.c` keeps the closed
  branch (the host H_p). An open point gives the opaque term `OP_ZK_HP`
  (one argument) or `OP_ZK_HP_AT` (two arguments), and `lower.c` lowers it.
- `OP_MODEXP` (core.h, Q-S7-10 (a)) is internal, with no surface name.
  Eval computes b^e mod p. `lower.c` sends it through IR_STMT_PRECOMPILE
  at address 0x05.
- `src/front/blsag.h` defines `RESTRICT_HP_TRIES` (K = 8u, Q-S7-12 (a)).
- `lower_hp` (Q-S7-14 (e1)) lowers an open H_p to a loop: the locals x, x
  + 1, found and c; IR_STMT_REPEAT K times: when found is 0, one try. A try
  computes rhs = x^3 + 3 mod p (MODEXP), s = rhs^E with E = (p + 1) / 4,
  and when x < p and s^2 = rhs, it sets x, y = min(s, p - s) and found :=
  1. Then c := c + 1. After the loop, when found is 0, TRAP. The found
  flag keeps the first counter that gives a point. The point is two
  locals, because `evm.c` does not lower IR_STMT_ALLOC. A point that is
  not two words is a refusal (REFUSE_LOWER, `test/lower/hp-point.lang`).
- The size (Q-S7-11 (a)): `--kit build examples/restrictkit.lang
  --runtime` is 15490 bytes after the review fixes, under 24576. Before
  review it was 13277 bytes; the unrolled form was 112810 bytes.
- Review fixes: verifier unrolling requires a complete list of point
  pairs, preventing a checker crash on a neutral point. Open H_p validates
  its input through ECADD with infinity before hashing it, matching the
  closed evaluator's rejection of off-curve coordinates. C regressions
  exercise the neutral-point proof and compare closed H_p with EVM execution.
- An empty ring slot also needs an H_p counter below K. At self 0x100,
  the generator needs counter 7 and the empty slot needs 23. `ringBound`
  refuses registration with that partial ring; filling the second slot
  with an admissible key restores service. The new Path rows cover both
  outcomes. `hpHasCounter` shares one H_p value across the counter tests.
- Chain rows: `test/precompile.sh` has 4 `hpX` rows at the word wC
  (zkKey 13 G, (0, 0), zkKey 1 G gives `trap`, and zkKey 3 G). zkKey 3 G
  has two counters below K, so its row kills a loop without the found
  flag. `test/restrict.sh` (new, after `test/dao.sh` in `make check`) has
  8 steps: issue with counters 0, 5 and 7, a bad counter, a key with no
  point (trap), an issue from dave (revert), and register from dave (ok,
  then revert).
- S7 s4 notes. `examples/natkit.lang` (state `n : Nat`, entry `setN (x :
  U256)` = `toNat x`, view `nOf`) and `test/run/natkit.script` (7 rows, a
  chain line in `test/evm.sh`) give the 4 USER values of Q-S7-16 (a): 0u
  and 18446744073709551615u set n, 18446744073709551616u and the largest
  U256 trap. FACT: eval prints `trap`, and on the chain the call stops at
  the TRAP arm with the Trap() selector (the result `trap` of
  `test/evmchain.sh`), not a plain `revert`. Thus "reverts on the chain"
  in Q-S7-4 is a revert with the Trap() selector. `test/evmchain.sh` has
  the new helper `outcome DUMP` (the result awk of `step`, no change in
  behavior); `tcall` in `test/restrict.sh` uses it. Sizes (`langc --kit
  build [--runtime]`, bytes = chars / 2): restrictkit runtime 16050 and
  initcode 16177, natkit runtime 138 and initcode 157 (limits 24576 and
  49152). Mutants: 14, all KILLED; the serial gate after the restores is
  byte for byte the s4 gate log. `lower_to_nat` TRAP in the true arm (the
  0u row) and LE to LT (the 2^64 - 1 row) fail in `test/evm.sh`. The 8
  guest mutants fail a Path row in the examples step: `fromDao` reads
  `self e`, `setCapN` writes the pCapCN position, `setLockD` without
  `fromDao`, `setRegD` writes `pLockD s`, `setPass` keys 0u, `setDecided`
  keeps `decided s`, `setIssuer` writes `flagYes` for each `f` (only the
  new row `setIssuerOff` kills it) and natkit `setN` stores 0. The token
  mutants fail in `test/restrict.sh`: no canTransfer call (alice to dave),
  no isVerified call (carol to bob), no transferred call (kit balanceOf
  dave), and `isVerified` renamed in the kit file (the ABI row). FACT:
  `langc --kit build` refuses a program with a failed Path row
  (PATH_END), so the chain leg of a guest mutant stops at deploy
  (restrict: 0 steps, 10 failures; evm: natkit deploy FAIL). The chain
  rows do not give a second kill for those mutants.
- S7 s5 notes. The kit CALL form (Q-S7-17 (a)): the keyword `call`
  (`src/front/lexer.c`), the declaration `call NAME (to : Addr) (w1 : T1)
  ...` (`src/front/parser.c`, parsed as `event`) and one `Out`
  constructor with the mark `call` (`src/front/check.c`). Field 0 must be
  `Addr`, and the other fields must have ABI word types, else REFUSE_CALL
  (the check rows `call-empty`, `call-field`, `call-field-name` and
  `call-target`, and the kit-only row `kit-call`). `src/lower.c` gives
  IR_STMT_CALL with NAME, the target word and the words of fields 1 to n;
  the lowertool row `call-name-setcapn` checks the name.
  `examples/restrictdao.lang` (Q-S7-18 (a)) is daokit with the ballot
  context: castSig uses zkVerifyAt at w = hash(selfWord, 1u), and `enact`
  gives `setCapN kitAddr (proposal s)` when yes > no (14 eval rows).
  FACT: the first chain run of the open H_p loop trapped. zkKey 0 has the
  H_p counter 19 at w, and K = 8, thus castSig stopped at the TRAP arm
  (pc 1583) after 8 loop turns. Eval accepted the ring (256 host tries,
  Q-S7-13). The fix is the key choice of Q-S7-20 (a): the rdao ring is
  zkKey 17, 36 and 2 (counters 0, 7 and 3 at w). `test/ballottool.c` has
  the key maps `dao_keys` {0, 1, 2} and `rdao_keys` {17, 36, 2}. The mode
  `rdao` checks the H_p counter of each ring point at w (below
  RESTRICT_HP_TRIES, else a failure) and prints the ring words first (238
  lines). The seed stays 40u + voter, thus the slot ciphertexts and the
  tally words do not change, and `ballottool dao` and `ballottool words`
  give the same bytes (cmp). `test/dao.sh` part 2 (Q-S7-19 (a)) has 30
  more steps on a second prestate (restrictdao at 0x..da, restrictkit at
  the receiver): the chain is 63 steps, 0 failures. The rdao size row:
  runtime 19632 and initcode 19667 bytes (limits 24576 and 49152). The
  gas row adds `rdao enact 128344`. Mutants: 9, all KILLED. Six fail a
  front, lower or eval row: `lower.c` names the call `transfer`
  (lowertool `call-name-setcapn`), `check.c` does not check field 0
  (`call-target` gives exit 0, not REFUSE_CALL), the `enact` flagIf arms
  are swapped (`enactOut` gives `some nil`), `sigOk` verifies at
  `selfWord` with no hash or as `zkVerify ring poll` (`stageSig` gives
  `none`), and `kitAddr` is ..6573 (the `enactOut` address). Three fail
  in `test/dao.sh`: `ballottool rdao` signs at pid 2 (castSig reverts, 25
  failures), `lower_hp` starts the tries at 1 (castSig reverts: the loop
  skips counter 0 of zkKey 17 and finds a later point, thus a revert, not
  a trap) and K - 1 tries (castSig traps at zkKey 36, counter 7). The
  serial gate after the restores is byte for byte the s5 gate log.
- S7 s7 notes. The USER s6 commit is 5282f47 (tree 910dfc92, parent
  26be5ba), not the staged tree 0e3b03d7: the USER changed the Q-S7-22
  (a) text (section 16) before the commit, and that text is the ruling
  for s7. It adds: `propose` checks each hc_i <= 7u before its `hpAt`
  (the restrictkit `issue` form), ctxOf and nullOf read `pid s`, and the
  regressions R1 and R2. Q-S7-25 (a stop of the first s7 prompt: ctxOf
  keeps `poll`) was not asked, because that text rules it.
  `examples/restrictdao.lang`: the state gets `pid` and `kind` (init 1u
  and 0u), the constants `proposer` and `period` (10u), three new `call`
  declarations (setCapCN, setLockD, setRegD), `ctxOf (p ix iy)` and
  `nullOf (p ix iy)` (no `poll`), `hpAt` and `both` (copies of the
  restrictkit defs), `propose (p hc0 hc1 hc2 k v)`, the `enact` Out by
  kind (Q-S7-23 (a)) and the views `pidNow` and `kindNow`. The eval has
  14 new restrictdao rows (28 in all), with R1 (proposeR1) and R2
  (sealR2). Q-S7-26 (a): each chain step at BLOCK > 0 is `evm t8n` from
  the key address 0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b
  (test/evmchain.sh:12), and `evm run` refuses a number > 0
  (test/evmchain.sh:131). Thus `proposer` is that address, and the eval
  envs e0, e11 and e22 have it as the caller (eOther has 0x..bb). The
  chain row "propose from the voter" is at BLOCK 0, thus it also reverts
  on the block check: the eval row proposeOther is the row for the caller
  check. `test/ballottool.c`: `dao` takes the pid, and the new mode
  `rdao16` gives the pid 16 counters 2, 3 and 4, the ballots b3 to b5 and
  the R2 attack words (a sum proof for the pid 1 image of b0 with the ctx
  at pid 16). `test/dao.sh` part 2: `kword SLOT NAME WANT` (`capn` for
  the kit slot 0x0b, `capcn` for 0x0c), and 26 new steps after the s5
  rows: propose from the voter, R1, propose 16 (kind 1, value 9), the
  views, a second propose at 16, the R2 row, the 3 casts at pid 16, a
  duplicate seal, `enact` at block 22, and then the kit pCapCN is 9. R2
  on the chain: the s5 rows seal all 3 ring keys at pid 1 (1 image for
  each key at a pid), thus a pid 1 ballot with no castSeal cannot be set
  up before the move. The eval row sealR2 is the R2 regression. The
  chain R2 row (castSeal of b0 with the attack words after the move)
  stays a revert row, but it reverts with or without the pid-bound
  nullifier (b0 at pid 1 is used, and at pid 16 its stage is 0). Size
  (the Q-S7-11 (a) stop): the first build gave the rdao runtime 30097
  bytes (limit 24576; HEAD 19632). Q-S7-27 (a): a breakdown probe before
  a cut. The State argument of sigOk cost about 6.3 KB, also when the
  body did not read it (nullOf and ctxOf with a State argument cost 0).
  `propose` cost 3481 (each `hpAt` site about 1 KB: the lowering inlines
  each call), the 4-way Out 464, the pid reads 83 and the 2 views 60.
  Q-S7-28 (a): sigOk takes the word w, and castSig calls `sigOk env (hash
  (selfWord env) (pid s)) ...` (the same word and the same checks). Not
  taken: (b) also removes the 2 views, (c) also removes the kinds 1 to 3.
  The runtime is then 23839 bytes (737 under the limit) and the initcode
  23879. The cause of the 6.3 KB in the lowering is not probed (O18). The
  serial gate (EXIT 0) against the s7 step0 log: evals 235 to 249
  checked, the rdao size row 19632/19667 to 23839/23879, the gas row
  `rdao enact` 128344 to 130578 and the new `rdao propose 124712`, and
  the chain 63 to 89 steps, 0 failures. Mutants: 10, all KILLED by an
  eval row (`make check` stops at that step, thus the chain rows do not
  run): the proposer check (proposeOther; the chain voter row is at
  BLOCK 0 and reverts on the block check also, thus it does not kill this
  mutant), p = pid passes (proposeSame), no `hpAt` for ring point 2
  (proposeBadHc2), no hc bound for ring point 0 (proposeR1, R1), k = 4
  (proposeK4), the Out swaps the kinds 1 and 2 (enactOut1), the castSig
  word at 1u (castOld), nullOf at 0u in place of the pid (sealR2, R2),
  and `propose` keeps casts or enacted (movedState). The serial gate
  after the restores is byte for byte the s7 gate log.

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
| S5 | Part C: the class partition (4.2), the issuer rings, `register` with the per-contract key image (O8), `isVerified`, expiry; L2, L7, L8 | DONE (2026-10-25): the kit ops `zkHpAt`, `zkSignAt` and `zkVerifyAt` (Q-S5-1 (a); the key image seed is hash(hash(P.x, P.y), w), and the old ops keep the same bytes) with the blsagtool context rows; `examples/restrict.lang` with Part C (section 3.4, S5 notes; 26 more `refl` paths: L2, L7, L8, the issue, register and class rows) and `test/run/restrict.script` (9 more rows). `make -B check` EXIT 0. No counter changes: the log is byte for byte the S5 step0 log, because S5 adds no example file and no run script, and the blsagtool context rows print no new line; 0 failures. Mutants: 6 (L2, L7, L8, the key image context, expiry, the class rule), 6 KILLED; the gate stops at the first failed step, so the second legs ran alone: M2 and M5 change run rows 20 and 21 (on the example without its `refl` rows, whose run output is `restrict.out`), and M4 fails three blsagtool context rows. The gate after the restore is byte for byte the S5 gate log |
| S6 | the DAO over the rules: `Params` for each parameter, the issuer list, rule-set amendment, encrypted ballots (O9) | s1 DONE (2026-10-25): STEP 0 gate EXIT 0, byte for byte the S5 gate log (HEAD daa2cae, with the USER bLSAG nonce fix); probes p1 to p6 (section 15); docs only; the USER ruled Q-S6-1 to Q-S6-8 (a). s2 DONE (2026-10-25): the port of intent-lang 3df9d96 (Q-S6-1 (a)) with the ballot context hash(selfWord, pid) (Q-S6-7 (a)); in `examples/restrict.lang` the `Params` words, the issuer map, the class pass set and the setters (section 3.1, S6 notes); `examples/charter.lang` with the charter law and the regime rows (section 4.4). `make -B check` EXIT 0. The changes from the step0 log: examples 51 -> 54 (`tally.lang`, `ballot.lang` and `charter.lang`; `charter.lang` is a third new example, so +3, not +2 as Q-S6-1 said), check refusals 187 -> 188 (`tally-leak.lang`), evals 188 -> 203 (tally 6, ballot 9), precompile steps 143 -> 152 (the ballot steps), and three new lines: the `ballottool` build, its check-clang row and `ballot regressions: passed`; the run counts do not change; 0 failures. The base is the S6 s1 step0 log (`restrict-lang-S6-step0-gate.log`): the s2 step0 log has `precompile: 152 steps checked` at line 76, not 143, because the `test/precompile.sh` hunk went in while that gate ran. Mutants: 8 (holderCap reads 2u, `issue` ignores the issuer map, `setCapN` writes `pCapCN`, `tallyEnc` drops the head ballot, a tie passes in `decide`, the ballot ctx drops pid, `active` keeps the old rule set, `yn` passes on a tie), 8 KILLED; the tie and ctx mutants pass their checks and fail the eval rows `tally kept` and `ballot sigGood`. The gate after the restore is byte for byte the S6 gate log |
| S7 | the contract writer: the ABI of section 7, the events, the entries of Q-S6-8 (a), chain rows on the test token (Q13) | s1 DONE (2026-10-25): STEP 0 gate EXIT 0, byte for byte the S6 gate log (HEAD 864849a, the USER S6 commit, with no fix); probes p1 to p7 (section 16): the writer refuses the kit file, the kit build refuses `either` (`canTransfer`, `step`) and `zkVerifyAt` over a state ring or a run-time context word; Q-S7-1 to Q-S7-9 OPEN at s1; docs only; then the USER ruled Q-S7-1 to Q-S7-9 (a). s2 DONE (2026-10-25): the base is USER 273914f, the s1 tree with a USER fix in this file (Nat is an ABI `uint64`; `toNat` accepts only values at most 18446744073709551615u, and a larger value traps in eval and reverts on the chain, Q-S7-4). The port of intent-lang S8 (`ef5abe8..c6636f1`) and S10 (`3df9d96..79e1898`; S6 had S9) (Q-S7-3 (a)): the `Env.block` prelude, `examples/blocks.lang`, `examples/daokit.lang`, `test/dao.sh` and the S10 kit code; `ballottool dao` signs the intent-lang form with no context word, and the S6 ballots do not change (section 6, S7 notes). The rules form builds `allowed.bit` from the rule bits (Q-S7-2 (a); section 3.3, S7 notes): the kit build of `examples/restrict.lang` now refuses `canTransfer` at the plain `mapGet` (the s3 kit maps), not at `either`. The kit op `toNat : U256 -> Nat` (Q-S7-4 (a)): eval traps above 2^64 - 1, and the lowering reverts (an IF with a TRAP arm); eval rows `natZero`, `natMax`, `natOver`, `natTop` and `natHigh` (2^192, limb 3 only); the chain rows are s4 work. The `Env` field `self : Addr` (Q-S7-6 (a)) lowers to ADDRESS (0x30), and a run script sets it with the line `env SELF` (section 6, S7 notes); the constant `self` is now `selfAddr` (rule R4; section 3.4, S7 notes), the 20 `makeEnv` sites get a fourth argument, and `examples/selfenv.lang` has the eval, run and chain rows. `examples/circle.lang` renames its `toNat` to `s1ToNat` (R4). `make -B check` EXIT 0, 120 lines. The changes from the s1 step0 log: the `ballottool` build and its check-clang row get `src/front/secp256k1.c` (lines 17 and 40); examples 54 -> 57 (`blocks.lang`, `daokit.lang`, `selfenv.lang`); evals 203 -> 221 (daokit 11, toNat 5, selfIs 2); runs 7 -> 10 (the `blocks`, `daokit` and `selfenv` scripts); run refusals 10 -> 15 (a bad BLOCK, four `env` rows); evm steps 43 -> 62 (16 S8 and S10 steps, 3 selfenv steps); five new lines: `sh test/dao.sh`, `dao size rows: runtime 16702 bytes (limit 24576), initcode 16737 bytes (limit 49152)`, `dao gas rows`, `dao chain: 33 steps, 0 failures` and `dao regressions: passed`; the two lowertool `to-nat` rows and the seven new `refl` rows print no new line; 0 failures. Mutants: 8 (the rules bit gives `flagYes`, `to_nat` tests `== 0`, `to_nat` does not test limb 3, `lower_to_nat` has no TRAP arm, `evm.c` emits CALLER for `self`, `lower.c` lowers `self` to CALLER, `run_env` takes an env line after a call, `run_env` takes a second env line), 8 KILLED; the limb-3 mutant fails only the eval row `natHigh`. The gate after the restore is byte for byte the s2 gate log. s3 DONE (2026-10-26): the base is HEAD 46a8860. The USER ruled Q-S7-10 to Q-S7-13 (a) and Q-S7-14 (e1) (section 16; the Q-S7-12 counters and the Q-S7-14 counts are there). The open zkHpAt in eval (an opaque `OP_ZK_HP` or `OP_ZK_HP_AT` term), the internal op `OP_MODEXP` (precompile 0x05), and the H_p loop `lower_hp` with K = 8 (`RESTRICT_HP_TRIES`; a found flag stops the tries; two locals for the point) (section 6, S7 s3 notes). `examples/restrictkit.lang`: `issue` takes the counter hc as a fifth word and checks `hpAt` at `selfWord` (Q-S7-13 (a): each ring point of a reachable state has a counter below K, so the closed eval and the chain agree) (section 3.4, S7 s3 notes). Size before review: the kit runtime was 13277 bytes (issue 1135, register 4412); after the review fixes it is 15490 bytes, under 24576. The unrolled form was 112810 bytes. Tests: the kit rows of restrictkit.lang, 4 `hpX` rows in `test/precompile.sh`, the refusal `test/lower/hp-point.lang`, and `test/restrict.sh` (8 steps). `make -B check` serial EXIT 0. The changes from the s3 step0 log: examples 57 -> 58 (`restrictkit.lang`); lower refusals 16 -> 17 and checks 33 -> 34 (`hp-point.lang`); precompile steps 152 -> 156 (the 4 `hpX` rows); three new lines: `sh test/restrict.sh`, `restrict: 8 steps checked` and `restrict gate: 0 failures`; 0 failures. Mutants: 8 (the counter starts at 1, REPEAT K - 1, the last byte of E, the found flag never stops the tries, no TRAP after the loop, `issue` skips `hpAt`, `u256Le hc 8u`, `selfWord` reads `caller`): 7 KILLED, 1 equivalent. The found-flag mutant passed the first gate; a probe of `hpX` found keys with two counters below K (zkKey j G for j = 3, 4, 5, 10, 14, 15, 17, 30), and the new row zkKey 3 G kills it. The `issue` and `selfWord` mutants fail the kit check (`issueNoPoint`, `selfEnvIs`) before the chain leg. `u256Le hc 8u` is equivalent on the chain: the loop traps for each key with no counter below K, and no key j in 0 to 40 has a point at counter 8 in eval. The gate after the restores is byte for byte the item 6 gate log; the last gate differs from it only at `precompile: 155 -> 156 steps checked`. s4 NEXT: the `toNat` chain rows for the 4 USER values (0u, 18446744073709551615u, 18446744073709551616u, the largest U256: the first two succeed, the last two revert), the `lower_to_nat` IF mutants (arm swap, IR_OP_LE -> IR_OP_LT; only a chain row kills them), the DAO entries, the test token (Q-S7-7 (a) `asmtool token`), the ABI row (Q-S7-8 (a)) and the EIP-170 check of the full contract. s4 survey (2026-10-26): the base is d460972 (tree 5034acfc), the USER s3 commit with review fixes (restrictkit runtime 15490 bytes); STEP 0 gate EXIT 0, byte for byte the s3 gate log; probes s4a to s4e (section 16): the ballot entries do not fit in restrictkit under EIP-170 (9086 bytes of room, `castSig` alone is about 9.2 kB), and no kit entry gives a word to `toNat`; Q-S7-15 and Q-S7-16 OPEN at the survey; docs only; then the USER ruled Q-S7-15 (a) and Q-S7-16 (a). s4 DONE (2026-10-26): the base is d460972. restrictkit gets the init field `dao : Addr` (0x..da) and 7 setter entries with the check `fromDao` (section 3.1); `examples/natkit.lang` and its run script give the `toNat` chain rows of the 4 USER values; the asmtool mode `token` is the test token (section 3.2); `test/restrict.sh` has 17 setter rows, 15 token rows, the ABI row (9 EIP selectors) and the size rows (restrictkit runtime 16050 and initcode 16177 bytes). Gate EXIT 0: examples 58 -> 59, runs 10 -> 11, evm steps 62 -> 69, restrict 8 -> 40 steps; 14 mutants KILLED (section 6, S7 s4 notes). s5 NEXT: the kit CALL form, `examples/restrictdao.lang` at 0x..da in the prestate and the link chain rows (Q-S7-15 (a)). s5 DONE (2026-10-26): the base is 9a7d6c0 (tree 408fc044), the USER s4 commit. The USER ruled Q-S7-17 to Q-S7-20 (a) (section 16). The kit CALL form (Q-S7-17 (a)), `examples/restrictdao.lang` with an `enact` that calls the restrictkit setter `setCapN` (Q-S7-18 (a)), the `test/dao.sh` part 2 chain rows (Q-S7-19 (a)) and the rdao ring zkKey 17, 36, 2 (Q-S7-20 (a)) (section 6, S7 s5 notes). `make -B check` serial EXIT 0, 126 lines. The changes from the s5 step0 log: examples 59 -> 60 (`restrictdao.lang`); check refusals 188 -> 193 and kit-only refusals 22 -> 23 (the `call` rows); evals 221 -> 235 (14 restrictdao rows); the new line `rdao size rows: runtime 19632 bytes (limit 24576), initcode 19667 bytes (limit 49152)`; the dao gas row adds `rdao enact 128344`; dao chain 33 -> 63 steps; 0 failures. Mutants: 9, all KILLED; the gate after the restores is byte for byte the s5 gate log. s6 NEXT: a survey of the open entries of Q-S6-8 (a) (`propose`, `openTally`) and the other setters of Q-S7-18 (a). s6 survey (2026-10-26): the base is 26be5ba (tree 7f2765de), the USER s5 commit; the STEP 0 gate is EXIT 0, byte for byte the s5 gate log. Docs only: the probes s6a to s6c (section 16, S7 s6 survey). restrictdao has the `ballot` (the 3 casts), the `openTally` (the open of T0 in `enact`) and the `enact` of Q-S6-8 (a), and no `propose`. Of the pids 1 to 16, only 1 and 16 have the 3 rdao ring counters below K = 8. The 4 U256 setters and a plain `propose` give a runtime of 20328 bytes. The kit build refuses an Addr field in a `call`. The USER ruled Q-S7-21 to Q-S7-24 (a). s7 NEXT: `propose` with the pid and the counter words (Q-S7-22 (a)) and the 4 U256 setters by kind (Q-S7-23 (a)); `openTally` stays in `enact` (Q-S7-24 (a)); then S8. s7 DONE (2026-10-27): the base is 5282f47 (the USER s6 commit; the USER edit of the Q-S7-22 (a) text is the s7 ruling, section 6 "S7 s7 notes"). restrictdao has `propose` (the pid, the counter bounds before each `hpAt`, the kind), ctxOf and nullOf at `pid s`, the `enact` Out by kind and the views `pidNow` and `kindNow`; `ballottool rdao16`; 14 eval rows (R1 proposeR1, R2 sealR2) and 26 chain steps. The USER ruled Q-S7-26 (a) (the proposer is the t8n key address), Q-S7-27 (a) (a breakdown probe before a cut) and Q-S7-28 (a) (sigOk takes the word w: the rdao runtime 30097 to 23839 bytes; O18). The serial gate is EXIT 0: evals 235 to 249, the rdao size row 23839/23879, the new gas row `rdao propose 124712`, the chain 89 steps, 0 failures. Mutants: 10, all KILLED; after the restores the gate log is byte for byte the s7 gate log. S7 CLOSED. S8 NEXT: the mutants, SPEC, VALIDATION and the close (row S8). |
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
  need the same form. One builds it; the others port it. CLOSED (S6,
  Q-S6-1 (a)): restrict-lang ports the intent-lang S9 form (3.1, S6
  notes).
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
- O13 the UAT regime of each vote kind (4.4). CLOSED (S6, Q-S6-6 (a)):
  each vote kind is Arrow-Debreu. The rows are in `examples/charter.lang`.
- O14 ecrecover comes with the port and has no use. Kept: S2 keeps it.
- O15 the guest poll id is fixed to 0 (H:310). Each DAO proposal needs a
  poll id: a change of the signature. CLOSED (S6, Q-S6-7 (a)): no
  signature change. The ballot context word is hash(selfWord, pid)
  through `zkVerifyAt`. The guest `zkVerify` keeps poll 0.
- O16 the transfer agent bullet: the token stays the record of ownership.
  The compliance contract keeps a mirror only (3.2). Kept.
- O17 the class map `cls` is written by hand in `examples/restrict.lang`
  (S5, Q-S5-3 (a)): S1 = {840} gives class 1, and the other countries give
  class 0. The rules form can compute `cls` from the sets of its rules: a
  change to `check_rules` (Q-S5-3 (b)). Kept: open.
- O18 a State argument to a def that holds `zkVerifyAt` adds about 6.3
  KB of runtime, also when the body does not read it (S7 s7, Q-S7-28
  (a): sigOk takes the word w). The cause in the lowering is not probed.
  Kept: open.

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

## 14. Questions of S5

STEP 0 (2026-10-24): the USER commit b7841d2 (parent 841b2c2) has the tree
191b7404, not the staged tree f5a5d22d. The USER added review fixes in six
files: dot-separated source names (src/front/lexer.c), the per-rule names
`R.rule.ri.holds` and `R.rule.ri.dec` (src/front/check.c, SPEC.md, section
13) and `rules_regressions` in test/fronttool.c. S5 takes b7841d2 as the S4
base. The S5 STEP 0 gate (`~/Documents/restrict-lang-S5-step0-gate.log`,
serial `make -B check`) gives EXIT 0 and is byte for byte the S4 gate log
(110 lines): `rules_regressions` adds no line to the log.

The S5 survey checked these facts with `build/langc --kit check` on the
probes in `~/Documents/restrict-lang-work/S5-probes/`:

- p1 prints ok. A state with `used : Map U256 Flag`, `clsOf : Map Addr
  U256`, `expires : Map Addr Nat` and two ring slot maps checks. `zkSign` and
  `zkVerify` check in a kit program def, and `refl` decides a closed
  `zkVerify`: yes for the signed poll, no for another poll. A class map `cls
  : U256 -> U256` by `flagIf` gives `Path U256 (cls 250u) (cls 276u)` by
  `refl` (the form of L2).
- p2: the value of a `Map` must be `Nat`, `Flag`, `U256` or `Addr`
  (`REFUSE_MAP`). Thus `Ring c` cannot be a `Map U256 (List ...)`.
- p3: `Env` has no contract address (`this` gives `NAME_UNKNOWN`). `Env` is
  `makeEnv now caller`.
- The kit bLSAG (examples/zk.lang, src/front/blsag.c, the op table at
  src/front/check.c:210): `zkSign ring x poll choice` and `zkVerify ring
  poll choice sig`. The signature is the word list `c_1, s_1 .. s_n, I.x,
  I.y`. The key image is `I = x * zkHp P`. It does not depend on the poll or
  on the contract: the poll id and the choice go into the challenge only.
  `zkHp` takes a point only (try and increment, the tag "orbit").

The questions. Q-S5-1 changes the kernel, so S5 stops at STEP 2 for the
USER rulings. The other questions are builder calls (a).

- Q-S5-1 the per-contract key image (O8). KERNEL. (a) A context word in the
  hash to curve. New kit ops in src/front/blsag.c and the op table:
  `zkHpAt P w` (the H_p of `hash (hash P.x P.y) w`), `zkSignAt ring x w m`
  and `zkVerifyAt ring w m sig`, with `I = x * zkHpAt P w`. `w` is the
  contract word and `m` is the wallet word. The old ops do not change, so
  the zk.lang lines of the gate stay. A row in test/blsagtool.c: one key in
  two contexts gives two key images, and each signature verifies in its own
  context only (section 8, ring rows). The chain verifier (MODEXP 0x05) is
  S7 work with the contract writer. (b) Keep `zkSign` and `zkVerify`, and
  use the contract word as the poll id. Then a key image links the wallets
  of one credential across contracts: O8 is not met. (c) Leave O8 to
  resolve-lang O10 and use (b) until then.
- Q-S5-2 the contract word. (a) A constant def `self : Addr` (as
  `testToken`) until the writer of S7, and `w := addrToU256 self`. (b) Add
  the contract address to `Env` (a kernel change to `Env` and the runner).
- Q-S5-3 the class partition (4.2). (a) Written by hand in
  `examples/restrict.lang`: `cls : U256 -> U256` by `flagIf` over the sets of
  the rules. For the 4.2 example, class 1 is `{840}` and class 0 is the
  other countries. `inSet` reads the classes, not the countries. L2 rows by
  `refl`: two countries of one class get the same `cls` and the same rule
  answers. The computation of `cls` from the rules form is later work (a
  new O17). (b) The rules form computes `cls` (a kernel change to
  `check_rules`).
- Q-S5-4 the rings (p2). (a) A fixed ring size n = 2 for each class. The
  slot maps `ringX, ringY : Map U256 U256` have the key `c * 2 + i`. `issue c
  i kx ky` writes slot `i` of class `c` and emits `Issued c i`. The issuer is
  a constant `issuer : Addr` until the issuer list of S6. `register` reads
  the two slots into the list for `zkVerifyAt`. (b) n = 3.
- Q-S5-5 `register`. (a) `register c c1 s1 s2 ix iy`: the five words of a
  signature for n = 2 (the entry builds the list). The key of `used` is
  `hash ix iy`. `register` reverts unless `zkVerifyAt (ring c) w (caller)
  sig` is yes and the key image is not used. It sets `used`, `clsOf caller
  = c` and `expires caller = now + regD` (a constant `regD` until S6), and
  emits `Registered c ix iy` (the class and the key image only, section 7).
  L7 holds by the `used` check.
- Q-S5-6 expiry, `isVerified` and `clsCode`. (a) `isVerified w := notF
  (natLe (expires w) now)`: an address that did not register has the end 0.
  `clsCode s a := mapGet (clsOf s) a`, so an address that did not register
  has class 0 and the S4 rows stay. L8 rows by `refl` at `now == expires -
  1` (yes) and `now == expires` (no). `register` reverts when the caller
  holds tokens and the class changes, so `holdersIn` stays exact; a renewal
  in the same class with a new key image is valid (O10). (b) `register`
  moves the holder count to the new class.
- Q-S5-7 the files. (a) The rows go into `examples/restrict.lang` (Q-S4-7
  (a)): the rules-class rows (L2), the L7 and L8 rows by `refl`, and run rows
  in `test/run/restrict.script` for `issue`, `register`, a second `register`
  with the same key image (revert) and expiry. `mirror.lang` does not
  change. (b) `test/check/rules-class.lang` with a copy of Part T.

The counters that S5 can change: blsagtool rows (Q-S5-1 (a)), the runs rows
of `restrict.script`, and no new example file (Q-S5-7 (a)).

USER rulings (S5, 2026-10-24): Q-S5-1 "(a) New *At ops"; Q-S5-2..7 "All
(a)". Thus each question of S5 is (a). Q-S5-1 (a) changes the kernel: the
new ops `zkHpAt`, `zkSignAt` and `zkVerifyAt`. The old ops do not change.

## 15. Questions of S6

S6 s1 (2026-10-25, claude2, docs only) surveys the DAO over the rules:
`Params` for each parameter, the issuer list, the rule-set amendment and
the encrypted ballots (O9). The probes are in
~/Documents/restrict-lang-work/S6-probes (the results are in `probes.out`).

STEP 0 facts:

- HEAD is daa2cae, a USER commit on b7841d2 ("Add S5 context-bound
  credential registration"). Its tree is 0ba52b8d, not the staged S5 tree
  610d6fb3, because the USER added a review fix. `git diff --stat 610d6fb3
  HEAD`: `src/front/blsag.c` (11 lines), `test/blsagtool.c` (8) and
  `test/run/restrict.script` (4); 16 insertions, 7 deletions. S6 takes
  HEAD as the S5 base.
- The fix. In S5, `sign` used nonce role 0 (alpha) and role 1 (the decoy
  responses) in the legacy mode (`w == NULL`) and in the context mode. Two
  signatures with the same key, ring, poll and choice, one in each mode,
  then had the same alpha and two different challenges, and the two
  responses give the private key. The context mode now uses roles 2 and 3.
  The legacy bytes do not change. A new blsagtool row signs in the two
  modes and prints "FAIL bLSAG signing modes disclose private key" if the
  key comes back. The context signatures change, so the two `register`
  rows of `test/run/restrict.script` (0x99 and 0x88) have new `c1 s1 s2`
  words. The key image words do not change, because the key image does not
  use the nonce. resolve-lang O10 shares the context ops: a port takes the
  fixed roles.
- `git status --porcelain`: only `.kanon-exec/`, `.kanon-replies/` and
  `.kanon-wait/` (not ours).
- Gate: ~/Documents/restrict-lang-S6-step0-gate.log (serial `make -B
  check`): EXIT 0, 110 lines, byte for byte the S5 gate log. The USER fix
  changes no gate line. The new blsagtool row prints nothing when it
  passes, and the run output of the two new `register` rows does not
  change, because `Registered` shows only the class and the key image.

Probe facts (`build/langc --kit check`, and the plain `check` for the
guest files):

- p1: intent-lang 3df9d96 `examples/tally.lang` as is: `ok` in the plain
  mode and in the kit mode. p1b: its `examples/ballot.lang` as is: `ok` in
  the kit mode (the plain mode gives REFUSE_KIT, as for each kit file). The
  restrict-lang kernel takes the S9 form with no change.
- S9 has no src change: `git diff --stat c6636f1 3df9d96 -- src` is empty.
  The src diff from the port base (`ef5abe8 3df9d96 -- src`: `check.c` 40
  lines, `contract.c` 2) is intent-lang S8 (c6636f1) only: `Env` gets
  `block : U256`, and a run call is `NOW BLOCK CALLER NAME ARGS...`. S6
  does not need it.
- p2: `Params` as state words (`pCapN : U256`, `pLockD : Nat`, `pRegD :
  Nat`). `holderCap` reads `pCapN s`, the rules form takes it, and
  `canTransfer` follows `setCap` (3 `refl` rows): kit `ok`. p2b: `Params :=
  Prod U256 Nat` as one state field: kit `ok`.
- p3: `member (caller e) issuers` over `List Addr`: kit `NAME_UNKNOWN` (the
  kit has no `member`); plain REFUSE_CELL (`List` is not a guest name).
  p3b: the issuer list as the state map `issuers : Map Addr Flag`. `issue`
  reads `mapGet (issuers s) (caller env)`, and `mapSet` adds or removes an
  issuer (4 `refl` rows): kit `ok`.
- p4: a rule-set amendment as `adopt c (ratify c r)`, with the rule set id
  `r : Size` (`ratifyRule`, D:223): `ok` in the plain mode and in the kit
  mode. A ratification names a rule set by a `Size`, not by its rules.
- p5 (O15): `zkVerifyAt r (hash selfWord pid) msg sig`, the poll id `pid`
  of a proposal in the context word of S5: kit `ok`. The key image seed is
  hash(hash(P.x, P.y), w) (Q-S5-1 (a)), so each key has one key image for
  each contract and proposal. The signature of the op does not change.
- p6 (O13, Q10 (b)): the median of a three-rung ladder from the opened
  counts (Black). `median` compares twice the running count with the total
  by `leB`; 3 `refl` rows (the counts 1/1/1 give mid, 2/0/1 low, 0/0/3
  high): plain `ok`.
- The UAT regimes (orbit-lang `design/DESIGN.md:39`,
  `examples/regimes.lang`): the regime of a menu at a tally counts its
  self-constituting outcomes. Arrow-Impossibility has none, Arrow-Debreu
  has one, Schelling-Ising has more than one.

Questions (the builder default is (a) in each):

- Q-S6-1 the port route (O9). (a) Port intent-lang 3df9d96 (its S9) as is,
  the same route as resolve-lang Q-S6-2 (a): `examples/tally.lang` (guest),
  `examples/ballot.lang` (kit), `test/ballottool.c`,
  `test/check/tally-leak.lang`, the tally and ballot eval rows, the ballot
  precompile steps and the Makefile rows of `ballottool`. `Choice` stays
  yes or no. The poll id comes from Q-S6-7. No src change (p1). The S8
  `Env.block` and the S9 rows of `examples/intent.lang` (Market, govern;
  they need S8) are not ported. Expected counters: examples +2, check
  refusals +1 (tally-leak REFUSE_LAW), evals +15 (tally 6, ballot 9),
  precompile steps +9, and the new line `ballot regressions: passed`.
  (b) Port `examples/tally.lang` and `tally-leak.lang` only (the guest
  law), and leave the kit ballot views and `ballottool` to S7. Fewer gate
  lines change, but S6 has no chain form of the ballot. RULED: (a).
- Q-S6-2 the `Params` set. (a) Four parameters, each one state word (p2):
  `capN` (U256), `capCN` (U256), `lockD` (Nat) and `regD` (Nat). The rule
  tests, `mint` and `regSet` read them from the state. `init` holds the S4
  and S5 values, so the values in the S4 and S5 `refl` rows and run rows
  stay. `capC` is a class code, not a parameter. The token binding
  (`decided`, Q-S3-2 (a)) is a DAO decision too. (b) One product field
  `Params` (p2b) that one decision sets as a whole. (b) has fewer polls,
  but each poll gives all four values. RULED: (a).
- Q-S6-3 the vote on a `Params` value (4.4). (a) A yes or no on one
  proposal (Q10 (a)). The proposal names one parameter and its new value.
  `decide` of intent-lang takes the new value on a pass, and a fail or a
  tie keeps the old value. (b) The ladder median of p6 for the numeric
  parameters (Q10 (b), not ruled in S1). (b) needs a ladder for each
  parameter and a one-hot ballot over the ladder. RULED: (a).
- Q-S6-4 the issuer list. (a) The state map `issuers : Map Addr Flag`
  (p3b). `issue` reads `mapGet (issuers s) (caller env)`. A DAO decision
  adds or removes one issuer (a proposal is an address and a flag). `init`
  holds the S5 issuer 0x..e1, so the S5 rows stay. A removed issuer cannot
  issue, but its keys stay in the rings until a new ring (O10). (b) A list
  that is fixed at compile time, with a new kit op `member` (p3:
  NAME_UNKNOWN). That is a kernel change, and the list changes only with a
  new contract. RULED: (a).
- Q-S6-5 the rule-set amendment (3.1, 4.4). (a) An amendment ratifies a
  rule-set id in the `Charter` (p4), and the history fold gives the active
  id. The contract has one compiled rules form, so an amendment changes
  the `Params` (Q-S6-2) and the class pass set of the country rule (`inSet`
  becomes a state map `Map U256 Flag`). A new rule kind is a new contract:
  the DAO decides its address, and the token binds it (`decided`, Q-S3-2).
  (b) The rules form takes a menu of rule sets and gives one `canTransfer`
  that selects by the active id. That is a kernel change to `check_rules`
  (section 3.3, S4 notes). RULED: (a).
- Q-S6-6 O13, the UAT regime of each vote kind. (a) Each vote kind is
  Arrow-Debreu (one self-constituting outcome). The yes or no vote has one
  outcome, because a tie keeps the old value (May, 4.4). The ladder (if
  Q-S6-3 (b)) has one outcome with the lower median (Black). S6 s2 adds
  guest `refl` rows in the form of `examples/regimes.lang` that count one
  outcome for the yes or no menu. (b) Record the regime in the docs only,
  with no rows. RULED: (a).
- Q-S6-7 O15, the poll id of each proposal. (a) No signature change. The
  ballot context word is `hash(selfWord, pid)` through `zkVerifyAt` (p5),
  and the ballot ctx of `examples/ballot.lang` uses `pid` in place of poll
  0 (as resolve-lang Q-S6-2 (a) uses the dispute id). The guest `zkVerify`
  keeps poll 0. (b) A poll argument for `zkVerify` and `zkSign`. That is a
  kernel change, and the rows of the old ops change. RULED: (a).
- Q-S6-8 the scope of S6 s2 (as resolve-lang Q-S6-5). (a) S6 s2 builds the
  port of Q-S6-1, the `Params` words and the rule tests that read them,
  the issuer map, the charter amendment law, the state setters
  (`setParam`, `setIssuer`) with `refl` rows, and the regime rows. The
  entries `propose`, `ballot` (the encrypted choice), `openTally` and
  `enact`, and the encrypted tally in the state, are S7 (the contract
  writer). (b) S6 s2 also adds these entries and their run rows to
  `examples/restrict.lang` and `test/run/restrict.script`. RULED: (a).

## 16. Questions of S7

S7 s1 (2026-10-25, claude2, docs only) surveys the contract writer, the
kit build of `examples/restrict.lang` and the DAO entries of Q-S6-8 (a).
The probes are in ~/Documents/restrict-lang-work/S7-probes (`run.sh`,
`run2.sh`, `run3.sh`; the results are in `probes.out`). Each probe runs on
a scratch tree from `git archive HEAD`, so the repo does not change.

STEP 0 facts:

- HEAD is 864849a, the USER S6 commit. Its tree is c0d9e088, the staged
  S6 tree, so the USER added no fix.
- `git status --porcelain`: only `.kanon-exec/`, `.kanon-replies/` and
  `.kanon-wait/` (not ours).
- Gate: ~/Documents/restrict-lang-S7-step0-gate.log (serial `make -B
  check`): EXIT 0, 115 lines, byte for byte the S6 gate log.

Sibling facts:

- intent-lang S10 (79e1898) writes its kit contract `examples/daokit.lang`
  by hand from the `ballottool dao` constants. Its `writer.c` does not
  change. The cast is `castSig`, `castSlot` and `castSeal` (43 words, at
  most 22 words in one call, O39). The tally has 8 words. `enact` opens
  slot 0 with the quorum {1, 2}. The runtime is 16702 bytes.
- resolve-lang S7 s1 (Q-S7-1 to Q-S7-8 OPEN) takes the same route (its
  Q-S7-2 (a)). Its K4c lowers `zkVerify` only over a closed ring (a state
  ring gives REFUSE_LOWER, its P2). One verifier is about 3.5 kB. The kit
  has no `u256Mul` and no `u256Div`. The kit `Env` has `now` and `caller`
  only, and no contract address (its Q-S7-6 (a): CHAINID and ADDRESS). It
  plans three build sessions (its Q-S7-4).

Probe facts (`build/langc`):

- p1a: `langc contract examples/restrict.lang --start 0` gives exit 1,
  `REFUSE_KIT: Move: Addr is a kit item outside the base span`. The writer
  runs in the plain mode only (`--kit contract` is USAGE in
  `test/gate.sh`). `src/front/writer.c` is the DAO writer of orbit-lang S9
  B1. It also needs the prelude `Member`, `Choice`, `Outcome`, `outcomeSet`
  and `menu` (REFUSE_CONTRACT), and it cannot take the 17-field state or
  the maps.
- p1b: `--kit check` gives `ok`. p1c: `--kit build` gives `REFUSE_LOWER:
  canTransfer: K4c does not lower either at a word position`. The rules
  form makes `canTransfer` (it is not a def of the file; `Dec` is a Sum).
  The Move eliminations of `step`, `moveFrom` and `moveTo` (lines 98, 100,
  123, 125) are `either` too. With the 86 `refl` defs removed (179 -> 93
  defs, the check is `ok`), the first refusal is the same. `abi` gives the
  same refusal, so the kit selectors are not printed yet.
- p7 (`run3.sh`): the S7-probes copy of the file without the `either` sites
  (`step`, `moveFrom` and `moveTo` are stubs, the rules form is removed,
  and `canTransfer` in `transferred` is `flagYes`). The build files are hex
  text, so the runtime is half the characters.
  - A, the state ring `ring s c` (line 237): `REFUSE_LOWER: register: K4c
    does not lower zkVerifyAt at a word position`. Without `register`, the
    build is `ok` with 1433 runtime bytes. The hooks lower with the stub
    `step`, so `inl` and `inr` for a Move are not a refusal.
  - B, a closed ring of two literal points with the context `selfWord`:
    the build is `ok` with 3510 runtime bytes. `register` and its verifier
    add about 2.1 kB.
  - C, the closed ring of B with a run-time context word (`addrToU256
    (caller e)`): the same refusal as A.
  - The cause (`src/front/eval.c`, `zk_verify` and `zk_unroll`): the
    evaluator unrolls the verifier only when the ring points are closed
    and, for `zkVerifyAt`, the context word is closed (line 1726). The
    build computes the H_i table (H_p of each ring point at the context
    word). An open ring or an open context word stays stuck, so the
    lowering refuses. The chain has no hash to curve yet (O8).
- EIP selectors (`cast sig`): `bindToken` 0x3ff5aa02, `unbindToken`
  0x40db3b50, `isTokenBound` 0x993e8b95, `getTokenBound()` 0x6a3edf28,
  `canTransfer` 0xe46638e6, `transferred` 0x8baf29b4, `created`
  0x5f8dead3, `destroyed` 0x8d2ea772, `isVerified` 0xb9209e33.
- p2: `setLockD s v` with `v : U256` gives `TYPE_MISMATCH ... type Nat,
  found U256`. `setIssuer s v flagYes` gives `... type Addr, found U256`.
  `toU256` (Nat -> U256) checks `ok`. The kit has no U256 -> Nat op and no
  U256 -> Addr op. Nat is an ABI type (`uint64`, H:200), while the common
  proposal value is U256 (`uint256`); passing it to a Nat setter still
  requires a checked conversion. The kind dispatch
  `flagIf (u256Eq k 0u) (setCapN s v) ...` is not measured.
- p3, p4: the intent-lang src diffs `3df9d96 79e1898 -- src` (S10, 4
  files, +17/-5) and `ef5abe8 79e1898 -- src` (S8 to S10) apply to HEAD
  with no conflict, and `langc` builds. `daokit.lang` still gives
  `NAME_UNKNOWN: castSeal: unknown name block` after the S8 to S10 port,
  because the S8 `Env.block` is in the domain prelude, not in src. The
  daokit size on this kernel is not measured.
- p5: `self` (0x..c0) and `selfWord` are build constants
  (`examples/restrict.lang` lines 202 and 203, `examples/ballot.lang` lines
  36 and 38).
- p6: `test/evm.sh` runs the examples contract, events, lists, map and
  residuals. `test/mock.sh` is a mock ERC-20 (`asmtool mock`,
  `transferFrom` with a mode in slot 0). No ERC-3643 test token exists.

Questions (the builder default is (a) in each). The USER ruled all nine
(a) on 2026-10-25: "Rulings: Take all recommendations".

- Q-S7-1 the route (p1a). (a) A kit contract by hand,
  `examples/restrictkit.lang`, built by `langc --kit build` (intent-lang
  S10, resolve-lang Q-S7-2 (a)). `writer.c` and its rows do not change.
  (b) A kit mode for `writer.c`. That is a writer change for the state
  fields, the maps and the Move sum. RULED: (a).
- Q-S7-2 `either` (p1c). (a) The rules form builds `canTransfer` from the
  rule bits (the `both` of the Flag tests, as `allowed.bit`), not from an
  `either` over the `Dec`. The L1 `refl` rows tie the bit to the `Dec`.
  The kit hooks call `stepT`, `stepM` and `stepB` directly, with no Move
  at the word level. No lowering change. (b) Extend K4c to lower `either`
  over a Sum (a tag word). That is a lowering change. RULED: (a).
- Q-S7-3 the port (p3, p4). (a) Port intent-lang `ef5abe8..79e1898` (S8 to
  S10): the src diff (no conflict), the S8 `Env.block` prelude, the t8n
  route, `ballottool dao` and the form of `test/dao.sh`. (b) S10 only,
  with no `block`. Then `daokit.lang` gives NAME_UNKNOWN. RULED: (a).
- Q-S7-4 the proposal words (p2). (a) The words `kind : U256`, `value :
  U256`, `who : Addr`, with `on : Flag` and `pid` as state words. A new kit
  op `toNat : U256 -> Nat` (with eval, check and lower rows) gives
  `pLockD` and `pRegD`. Nat is a uint64: `toNat` accepts only values at
  most 18446744073709551615u. An out-of-range value traps in eval and
  reverts on the chain, without truncation or wrapping. The rows cover
  0u, 18446744073709551615u, 18446744073709551616u and the largest U256;
  the first two succeed and the last two fail in eval and on the chain.
  (b) `pLockD`, `pRegD`, `lockEnd` and
  `expires` become U256. Then the S4, S5 and S6 rows change. RULED: (a).
- Q-S7-5 `register` on the chain (p7). (a) A state ring. The chain
  computes H_p of each ring point at the context word (O8): an unrolled
  try and increment with a bound K on the counter, the square root by
  MODEXP 0x05 (the BN254 p is 3 mod 4), and a revert when no counter
  below K gives a point. `issue` reverts for a key with no point below K.
  The kit lowering gets an open form of `zk_unroll`: n = 2 is fixed at the
  build, and the ring points and the context word are run-time words. The
  eval rows of the S5 ops do not change. `issue` and the issuer map
  (Q-S6-4 (a)) stay run-time entries, and Q-S7-6 (a) can be ruled. s2 sets
  K from the counters of the test keys. (b) Closed rings. The ring of
  class c is a closed list in the contract (a `flagIf` on c over two rings
  of build-constant keys), and the context stays `selfWord` (Q-S7-6 (b)).
  No lowering change (p7 B: 3510 bytes). `issue` has no effect on the
  chain: a new key is a new contract (O10). RULED: (a).
- Q-S7-6 `self` (p5). (a) The resolve-lang Q-S7-6 (a) form: `self` is an
  `Env` word that lowers to ADDRESS (0x30), and `selfWord` is `addrToU256
  (self env)`. This needs Q-S7-5 (a), because a run-time context word
  refuses now (p7 C). (b) `self` stays a build constant, and the chain rows
  deploy at 0x..c0. (b) works with the two forms of Q-S7-5. RULED: (a).
- Q-S7-7 the test token (p6, Q13). (a) A new `asmtool token` mode: its
  transfer calls `isVerified`, `canTransfer` and then `transferred`, and
  its mint calls `created`. A chain test in the form of `test/dao.sh`. (b)
  A Solidity token. That is a new tool. RULED: (a).
- Q-S7-8 the ABI (O6). (a) An abi row checks the kit selectors against the
  EIP list above. (b) A doc check only. RULED: (a).
- Q-S7-9 the size and the split. The daokit runtime (16702 bytes), the
  compliance entries (p7 A: 1433 bytes with the stubs) and the verifier
  (p7 B: about 2.1 kB) come near the EIP-170 limit (24576), before the H_p
  of Q-S7-5 (a). (a) Three build sessions, as resolve-lang Q-S7-4. A size
  over EIP-170 is a STOP and ask. (b) Two contracts (compliance and DAO).
  The kit CALL pays and pulls only (H:88). RULED: (a).
- Q-S7-10 the MODEXP op (s3). (a) Within Q-S7-5 (a): one internal op
  with no surface name. Eval computes it. lower.c sends it through the
  IR_STMT_PRECOMPILE statement at address 0x05 (6 input words: 32, 32,
  32, b, e, p; 1 output word). It also gives x^3 (MODEXP(x, 3, p)) and the
  s^2 test (MODEXP(s, 2, p)). No MULMOD or ADDMOD op, and no new IR
  statement kind. x^3 + 3 is u256Add (no overflow, because p < 2^254),
  then a subtraction of p when the sum is at least p. RULED: (a) (USER
  2026-10-25).
- Q-S7-11 the size (s3). (a) As Q-S7-9 (a): build with the measured K,
  record the size, and when the restrictkit runtime is over 24576 bytes,
  STOP and ask. No word-term memo in lower.c, and no pair-selection
  probe, without a new ruling. RULED: (a) (USER 2026-10-25).
- Q-S7-12 the test keys and K (s3). The chain word is
  0x7265636569766572 (the receiver address of test/evmchain.sh; the `env`
  line of a call script gives the same `self`, thus the eval rows and the
  chain rows have the same H_p counters). The counters at this word:
  zkKey 0 = 29, 1 = 11, 2 = 5, 3 = 3, 4 = 3, 5 = 2, 6 = 4, 7 = 12, 8 = 1,
  9 = 1, 10 = 2, 11 = 14, 12 = 23, 13 = 0, 14 = 3, 15 = 0, 16 = 2,
  17 = 0, 18 = 7, 19 = 11, 20 = 11, 21 = 2, 22 = 6, 23 = 9, 24 = 14,
  25 = 19, 26 = 9, 27 = 14, 28 = 1, 29 = 12, 30 = 0, 31 = 0; the empty
  slot (0, 0) = 7. One try succeeds with a probability of about 0.095,
  thus the mean counter is about 10. The size is about 3.5 kB plus about
  1.4 kB for each unit of K (n = 2), thus K is at most about 14 under
  24576 bytes. With zkKey 0, 1 and 2, K = 30 and the size is about 46 kB.
  (a) restrictkit picks its test keys by their counters at the chain
  word, with K = 8 (the empty slot needs K >= 8): zkKey 13 (counter 0,
  it kills the mutant "the tries start at 1"), 2 (5) and 18 (7, it kills
  the mutant "K - 1 for K"). The refusal row uses zkKey 1 (11 >= K). The
  size is about 15 kB. The PLAN records the keys, the counters, K and the
  size. examples/restrict.lang keeps zkKey 0, 1 and 2 at 0xc0 (its eval
  rows do not change). (b) Keep zkKey 0, 1 and 2: K = 30 and the size is
  over 24576 (a Q-S7-11 (a) STOP). (c) A smaller chain for each try (a
  word-term memo in lower.c or a pair-selection probe). This needs a new
  ruling, because Q-S7-11 (a) excludes it. RECOMMEND: (a). RULED: (a)
  (USER 2026-10-25).
- Q-S7-13 the closed eval path and K (s3). Q-S7-12 (a) sets K = 8. On the
  chain, H_p of a run-time ring point reverts when no counter below K
  gives a point. The closed eval path of zkVerifyAt (blsag_verify_at),
  zkSignAt and zkHpAt uses the host H_p with 256 tries (BLSAG_HP_TRIES),
  thus the eval accepts a ring that the chain refuses (zkKey 1 at the
  chain word: counter 11). A bound K on the closed path changes S5 eval
  rows: the ring of class 1 in examples/restrict.lang holds zkKey 0
  (counter 21 at 0xc0), thus regDave, l7Verifies, renewDave and img0
  trap. With K = 8, about 45 % of the keys have no H_p at a given word
  (0.905^8). (a) Agreement on the reachable states: `issue` in
  restrictkit refuses a key with no H_p counter below K at selfWord, thus
  each ring point of a reachable state has a counter below K, and the
  closed eval and the chain give the same H_p. An open zkHpAt (an open
  point or word) reduces to the open chain of zk_hp_term (the same bound
  K; today it is opaque and does not lower). The guest check in `issue`
  is a fold over the counters c from 0 to K minus 1: u256Eq (first
  (zkHpAt k selfWord)) (hash (hash (hash kx ky) selfWord) c). The eval
  refuses with `none`, and the chain reverts in the open chain. No new
  op, no new IR statement kind and no new precompile route. The size is
  about 21 kB (an estimate: 15 kB plus a third chain). (b) A recorded
  divergence, with no code change: the eval rows of restrictkit use keys
  below K only, and the refusal of zkKey 1 is a chain row and a guest
  counter row (counter 11, not below K). The eval accepts a ring that the
  chain refuses (fail closed). (c) Bound the host H_p of the "at" ops at
  K (blsag_hash_point_at), thus the eval and the chain agree on each
  state, and move zkKey 0 in Part C of examples/restrict.lang to a key
  with a counter below K at 0xc0 (zkKey 3 or 6: counter 0). The S5 row
  verdicts stay, but the row text changes, and the keys of ballot.lang
  at its proposal word are not measured. RECOMMEND: (a). RULED: (a)
  (USER 2026-10-25).
- Q-S7-14 the runtime size of restrictkit (s3). A Q-S7-11 (a) STOP: the
  runtime of examples/restrictkit.lang is 112810 bytes (the limit is
  24576). The counts come from a copy of the kit in $TMPDIR with the asm
  limits raised and a byte count for each entry (src/ does not change;
  the copy gives the same bytes as build/langc for the 15 kit files that
  build). (A) The file: 112810 (issue 57678, register 47402, the other 12
  entries and the dispatcher 7730). (B) issue with one chain use (hpAt
  at 0u): 62585 (issue 7453). (C) No chain in issue: 55419 (issue 287).
  (D) C without register: about 8006 (from the entry counts). At K = 1:
  B is 17330 (issue 1244, register 8356) and C is 16373. Thus one try of
  the open chain is about 887 bytes, one chain at K = 8 is about 7166
  bytes, and register lowers about 6 chains (39046 bytes for 7 tries),
  not 2: each use of a coordinate of an open H_p point lowers the chain
  again (the memo gap of Q-S7-11). register alone is over the limit, thus
  hpOk is not the only cause. (a) A word-term memo or a let in lower.c (a
  new ruling: Q-S7-11 (a) excludes it): issue about 8 kB, register about
  17.4 kB (2 chains), the total about 33 kB: over. (b) A counter word as
  an argument of issue (an ABI change): issue 7453 (as B), the total
  62585: over. A counter argument does not help register: the chain must
  still refute each counter below it, or a key gets a second H_p point
  and a second key image (L7). (c) Two contracts (Part C in a second
  contract): the Part C contract is about 105 kB, or about 25.5 kB with
  (a): over. (d) A lower K: K = 8 is the minimum for the test keys. K = 1
  with new test keys (counter 0) gives 17330 (measured), but about 90 %
  of the keys at a word then have no point (the Q-S7-13 figure: 0.905 for
  each try). (e) The open chain as a loop: lower.c lowers zk_hp_term
  through IR_STMT_REPEAT (K runs of one try body; a flag stops the tries
  after a point; evm.c already lowers REPEAT), not as K unrolled tries.
  This changes the Q-S7-5 (a) text ("an unrolled try and increment"), but
  adds no IR statement kind and no op. A chain is then about one try
  (about 1 kB) for each K. (e1) K = 8, and issue takes the counter c as a
  fifth word (b): issue checks `u256Le c 7u` and the one term u256Eq
  (first (zkHpAt k w)) (hash (hash (hash kx ky) w) c). The test keys, the
  refusal row of zkKey 1 and the Q-S7-13 (a) argument stay. About 17.6 kB
  (B at K = 1 plus the loop code). (e2) K = 256 (the host
  BLSAG_HP_TRIES): the eval and the chain agree on each state, thus issue
  drops hpOk, with no ABI change (Q-S7-12 (a) and Q-S7-13 (a) change).
  About 16.6 kB (C at K = 1 plus the loop code). But no real key has no
  point below 256, thus the refusal row goes, and a chain H_p can run 256
  tries. The (e) sizes are estimates. RECOMMEND: (e1). RULED: (e1)
  (USER 2026-10-25).

S7 s4 survey (2026-10-26). The base is d460972 (tree 5034acfc), the USER
s3 commit with review fixes (the complete ring before the unroll, the G1
check before the open H_p, `ringBound` in `register`). The STEP 0 gate is
byte for byte the s3 gate log. Probe facts:

- s4a: `langc --kit build --runtime` gives restrictkit 15490 bytes, daokit
  16702, selfenv 119. The room in restrictkit under EIP-170 is 9086 bytes.
- s4b: resolve-lang (the same S10 DAO port, its probe B) measured the DAO
  entries: `castSig` 9156, `castSlot` 3670, `castSeal` 3905, `openTally`
  3597, `propose` 573, about 20.9 kB. Thus `castSig` alone is more than
  the room in restrictkit.
- s4c: `IR_STMT_CALL` has a function name and typed fields, but
  `src/lower.c` (line 939) gives only `transfer` (pay) and
  `transferFrom` (pull) (H:88). No kit CALL can send a decision to
  another contract.
- s4d: `toNat` has eval rows only (`examples/words.lang`). The kit build
  of `words.lang` refuses ("a build needs a state and def init : State"),
  and no kit entry gives a U256 word to `toNat`.
- s4e: the `--kit abi --text` output of restrictkit has the 9 EIP
  selectors above. The chain gate (`test/evmchain.sh`, `genesis TIME
  ALLOC`) takes more than one account, thus the test token and
  restrictkit can run in one prestate.

- Q-S7-15 the DAO entries and EIP-170 (s4). The ballot entries do not go
  into restrictkit (s4a, s4b), and Q-S7-9 (a) makes this a STOP. (a) Two
  contracts with a link. restrictkit keeps the compliance and identity
  entries, and gets an init field `dao : Addr` and the setter entries
  (the S6 `setParam` and `setIssuer`, and the class pass set and
  `decided`): each one checks `addrEq (caller env) (dao s)`. A new
  contract `examples/restrictdao.lang` is the daokit port with the ballot
  context hash(selfWord, pid) (Q-S6-7 (a)). Its `enact` sends the
  decision to the setter through one new kit CALL form: an `Out` that
  names a setter of restrictkit, lowered as IR_STMT_CALL with that name
  and its words (s4c). The Nat params (`pLockD`, `pRegD`) come as U256
  words through `toNat`. The slices: s4 = the setters, the `toNat` rows,
  the test token, the ABI row and the size rows; s5 = the CALL form,
  restrictdao and the link chain rows. This is one build session more
  than Q-S7-9 (a). restrictkit with the setters is about 17 to 18 kB (an
  estimate: about 500 bytes for each setter, as resolve-lang `propose`).
  (b) Two contracts with no link in S7. restrictkit keeps its init
  constants (the `Params`, the issuers, `decided`). restrictdao is a
  separate contract with its own chain rows. The link is a new open item
  for a later slice. (c) One contract: the DAO entries in restrictkit
  without the encrypted ballot (a member vote with no ring and no
  ElGamal, about 1 to 2 kB, an estimate). O9 then holds in eval only
  (`examples/ballot.lang`), not on the chain. RECOMMEND: (a). RULED: (a)
  (USER 2026-10-26).
- Q-S7-16 the `toNat` chain rows (s4d). (a) A new kit example
  `examples/natkit.lang`: the state `n : Nat`, the entry `setN (x :
  U256)` that sets n to `toNat x`, and the view `nOf`. The run script
  `test/run/natkit.script` has the 4 USER values (0u and
  18446744073709551615u give ok and the `nOf` value, 18446744073709551616u
  and the largest U256 revert), chained in `test/evm.sh`. The arm swap
  mutant fails the 0u row, and the IR_OP_LT mutant fails the
  18446744073709551615u row. Examples 57 -> 58 and runs 10 -> 11. This
  does not wait for Q-S7-15. (b) The rows on the Q-S7-15 (a) setter of
  `pLockD`. No new example, but the rows need the `dao` caller. (c) An
  entry `setN` in `examples/selfenv.lang`. No new example, but that file
  is the `self` example. RECOMMEND: (a). RULED: (a) (USER
  2026-10-26).

S7 s5 survey (2026-10-26). The base is 9a7d6c0 (tree 408fc044), the USER
s4 commit. The STEP 0 gate is byte for byte the s4 gate log. Probe facts:

- s5a: `IR_STMT_CALL` in `src/evm.c` (line 317) takes any name and typed
  words: the selector is the keccak of name(types) (`event_topic`), and
  the success test passes a callee with code and no return data (a kit
  entry ends in STOP). Thus the CALL form needs no change in `src/evm.c`.
  Only `src/lower.c` is about tokens: `out_call` (line 894) and
  `lower_call` (line 939) know only `pay` and `pull` of the prelude `Out`
  (`src/front/contract.c`).
- s5b: an event is `event NAME fields` (`src/front/parser.c` line 571,
  TOK_KW_EVENT), and `check_event` (`src/front/check.c` line 3461) adds one
  `Out` constructor with `event = 1`. The word `call` is not a name in
  `examples/`, `test/*.lang`, `test/check` or `test/lower` (comments only).
- s5c: the daokit `proposal` (4u) and `window` (6u) are init constants,
  and `enact` moves `window` to `proposal` when yes > no. daokit has no
  `propose` entry. Its casts verify with `zkVerify` (poll 0), thus
  `build/ballottool dao` signs with no context word (S7 s2 note).
  restrictkit `register` already lowers `zkVerifyAt` with `selfWord e`.
- s5d: `test/dao.sh` has the ballot words (`ballottool dao`, `ws`) and the
  t8n steps at BLOCK 11 (`numbered=1`). `test/restrict.sh` `tcall` has the
  two-account prestate (the test token at 0x..ee, restrictkit at the
  receiver).

- Q-S7-17 the kit CALL form (s5). An `Out` must name a restrictkit setter
  and give its words (Q-S7-15 (a)). (a) A new declaration `call NAME (to :
  Addr) (w1 : T1) ...`, parsed as `event` (a new keyword `call`). The
  checker adds one `Out` constructor with a new mark `call` (not `event`,
  thus `langc abi` does not show it as an event). Field 0 must be `Addr`
  (the target), and the other fields must have ABI word types
  (REFUSE_CALL). The lowering gives IR_STMT_CALL with NAME, the target
  word as `expr` and the words of fields 1 to n. NAME and the types must
  be those of the setter (setCapN(uint256) is 0x3b76bd56), and a chain row
  checks it. Eval keeps the constructor as a value in the `Out` list.
  Rows: a check row for each refusal, a `test/lower` row, the chain rows.
  (b) A prelude constructor `call (callTo : Addr) (callSel : U256)
  (callWords : List U256)`. No parser change. But the guest writes the
  selector as a number (no check against the setter name), and a `List`
  field of `Out` has no EVM lowering now (`emit` has none), thus the
  lowering needs a walk of the list. (c) The `event` declaration with a
  name rule (for example `event callSetCapN`), lowered as a CALL. No new
  keyword, but a name changes the meaning, and `langc abi` shows it as an
  event. RECOMMEND: (a). RULED: (a) (USER 2026-10-26).
- Q-S7-18 the decision that restrictdao sends (s5). (a) One setter.
  restrictdao is daokit with the ballot context of Q-S6-7 (a), a constant
  `kitAddr` (0x7265636569766572) and one declaration `call setCapN (to :
  Addr) (v : U256)`. `proposal` is the new holder cap. When yes > no,
  `enact` moves `window` to `proposal` (as daokit), and its `Out` list is
  `setCapN kitAddr (proposal s)`. A tie or a no gives an empty list. The
  other setters wait for a `propose` entry and a proposal kind (a later
  slice). (b) A proposal kind for the 4 U256 setters: the state gets
  `kind : U256`, and `enact` sends `setCapN`, `setCapCN`, `setLockD` or
  `setRegD` for the kind 0 to 3. A kind above 3 traps. Eval rows for each
  kind, chain rows for one kind. Four declarations, about 0.5 kB more (an
  estimate). (c) All 7 setters: a kind, a U256 word, an Addr word and a
  Flag word in the state. The largest form, and the Addr and Flag setters
  need more init constants. RECOMMEND: (a). RULED: (a) (USER 2026-10-26).
- Q-S7-19 the link chain rows (s5). (a) In `test/dao.sh`, which has the
  ballot words, `ws` and the t8n steps. A new `ballottool` mode `rdao`
  signs the 3 ballots at w = hash(0x..da, 1u) (`blsag_sign_at`, the S6
  form). A second prestate has restrictdao at 0x..da and restrictkit at
  the receiver. Rows: the casts and `enact` to 0x..da give ok, then the
  restrictkit cap view gives `proposal`; a direct `setCapN` to restrictkit
  from the voter address reverts; a second `enact` reverts (`enacted`).
  The restrictdao size rows go on the size line (runtime 24576, initcode
  49152). (b) In `test/restrict.sh`, which has `tcall` and the
  two-account prestate but not the ballot words or the t8n steps: it gets
  them from `test/dao.sh` by copy. (c) A new script `test/link.sh`. The
  ruling of 10-09 (no new shell harness) is against it. RECOMMEND: (a).
  RULED: (a) (USER 2026-10-26).
- Q-S7-20 the rdao ring and K (s5). The castSig chain row traps: zkKey 0
  has the H_p counter 19 at w = hash(0x..da, 1u), and K = 8 (zkKey 1 = 4,
  zkKey 2 = 3). Eval accepts the ring (256 host tries, Q-S7-13). (a) Pick
  the rdao ring by the counters at w, as Q-S7-12 (a) did for restrictkit:
  zkKey 17 (counter 0, it kills the mutant "the tries start at 1"), 36 (7,
  it kills "K - 1 for K") and 2 (3). Test data only: the ballottool rdao
  key map, the restrictdao.lang ring words and its eval rows. w, K and the
  lowering do not change. (b) Keep zkKey 0, 1, 2 and change the poll id
  in w so the 3 counters are below 8 (it changes the w of Q-S7-19 (a)).
  (c) A closed w word in restrictdao.lang: the closed path with host H_i
  words and no H_p loop (the signature is not bound to the run-time
  selfWord; a change to Q-S7-19 (a)). (d) Raise K: about 2 kB for each
  unit of K with n = 3, and zkKey 0 needs K >= 20, so the runtime goes
  over 24576 (a Q-S7-11 (a) STOP). RECOMMEND: (a). RULED: (a) (USER
  2026-10-26).
- S7 s6 survey (2026-10-26, docs only). STEP 0: HEAD 26be5ba (tree
  7f2765de, the USER s5 commit); `make -B check` serial EXIT 0, 126 lines,
  byte for byte the s5 gate log. The probes do not edit the repo; they are
  kept in `restrict-lang-work/S7-s6-probes` (outside the repo).
  - s6a (`awk` windows of `examples/restrictdao.lang`). The `ballot` of
    Q-S6-8 (a) is the 3 casts: castSig (the ring signature over the 8 slot
    words), castSlot (the OR proof of slot j) and castSeal (the sum proof,
    then T0 and T1 get the slots). The encrypted tally is the state words
    t0ax to t1by. The `openTally` is the `openSum` check of T0 in `enact`
    (two DLEQ shares of the quorum {1, 2}); it has no entry and no state
    of its own. `enact` is the entry `enact`. `propose` has no form:
    `proposal` (4u) and `castEnd` (10u) are init words, the ring context
    word is `hash (selfWord env) 1u` (line 298), the nullifier ctx uses
    the constant `poll` 0u (line 286), and `enacted` is set one time.
    Thus restrictdao has one proposal for each deploy.
  - s6b (`hpprobe.c`, linked with the BALLOT_TOOL sources:
    `blsag_hash_point_at` of zkKey 17, 36, 2 at w = hash(0x..da, pid)).
    The counters for pid 1 to 16: 1: 0 7 3; 2: 19 1 0; 3: 6 22 37; 4: 4 7
    23; 5: 8 8 16; 6: 4 61 15; 7: 23 3 6; 8: 9 16 12; 9: 40 22 29; 10: 0
    17 31; 11: 1 12 4; 12: 30 2 0; 13: 7 8 17; 14: 14 1 27; 15: 15 16 21;
    16: 2 3 4. Only pid 1 and pid 16 have the 3 counters below K = 8. At
    the other 14 pids a castSig traps on the chain (the TRAP arm after
    the H_p loop) and passes in eval. Thus a `propose` that adds 1 to the
    pid stops the votes of most proposals. The H_p base takes w
    (`test/ballottool.c` line 614), so a new pid gives new key images and
    new nullifiers, and `used` needs no reset. A raise of K is about 2 kB
    for each unit of K (Q-S7-20 (d)), and the probe has counters to 61.
  - s6c (`sizeprobe.sh`: copies of restrictdao.lang in $TMPDIR,
    `build/langc --kit build PROG --runtime`, bytes = chars / 2). Base:
    runtime 19632, initcode 19667. Q-S7-18 (b) (`kind : U256` in the
    state, 4 `call` declarations, a 4-way `Out` in `enact`): runtime 20096
    (+464), initcode 20131. (b) with a plain `propose` (it checks k <= 3,
    writes kind, proposal and castEnd, and clears T0, T1 and casts; no pid
    and no `hpAt` check): runtime 20328 (+696), initcode 20363. Q-S7-18
    (c) (also `pAddr : Addr` and `pFlag : Flag`, 7 `call` declarations):
    the kit build refuses it with `TYPE_MISMATCH: enact: expected a term
    of type U256, found a term of type Addr` (an Addr field after `to` in
    a `call`; the cause is not probed). The room under 24576 after (b)
    with `propose` is 4248 bytes. The 3 `hpAt` checks of Q-S7-22 (a) are
    not measured.
- Q-S7-21 the S7 scope after s6. (a) One more S7 build slice (s7):
  `propose` (Q-S7-22) and the proposal kind (Q-S7-23) in
  restrictdao.lang, with eval rows and `test/dao.sh` chain rows for a
  second proposal; then S8. (b) S7 closes now: restrictdao keeps one
  proposal for each deploy, and `propose` and the other setters go to a
  later stage (a new row after S8). S8 then has the mutants, SPEC,
  VALIDATION and the close of S1 to S7 only. RECOMMEND: (a). The s6c room
  is 4248 bytes, and Q-S7-22 (a) uses the s3 form (`hpAt`, Q-S7-13 (a)),
  not a new lowering. RULED: (a) (USER 2026-10-26).
- Q-S7-22 the `propose` entry (s6b). (a) The proposer gives the pid and
  the counters. The state gets `pid : U256` (init 1u, the s5 proposal).
  `propose (p hc0 hc1 hc2 k v)` gives `none` unless: the caller is
  `proposer` (a constant, 0x..aa in the rows), block > castEnd s (no open
  cast window), p > pid s, each hc_i <= 7, and `hpAt` of ring point i
  at hash(selfWord, p) with hc_i, for i = 0, 1, 2. Check the counter
  bounds before `hpAt`, as in restrictkit `issue`: `hpAt` alone does not
  bound a counter. Each reachable pid then has its 3 counters below K,
  so eval and the chain agree (Q-S7-13 (a)). Then pid := p, kind := k,
  proposal := v,
  castEnd := block + `period` (a constant), T0 and T1 := (0, 0), casts
  := 0 and enacted := no. sigOk reads `pid s` in place of 1u; ctxOf
  and nullOf read `pid s` in place of `poll`. All used, pend and stage
  accesses use this pid-bound nullifier, including castSlot, castSeal
  and stageOf. Retain used; older pending casts remain in their old
  namespace and cannot be sealed in a new proposal. A proposal that is
  not enacted before the next `propose` lapses. `ballottool rdao`
  regenerates the initial pid 1 proof contexts and gives the next good
  pid (16) and its counters. Required eval and chain regressions:
  reject `propose 2u 19u 1u 0u 0u 4u` at block 11 from proposer (the
  counter tuple passes `hpAt` in eval without the bounds); leave an
  initial-pid ballot after castSig and both castSlot calls, then propose
  pid 16 and reject castSeal on the old image even with a fresh sum
  proof for ctxOf at pid 16. A fresh pid 16 cast still succeeds, and a
  duplicate seal is rejected. (b) As (a), but any caller can propose. A caller can then
  propose after each close, before the real proposer. (c) pid := pid + 1
  with no counter words: 14 of the pids 1 to 16 trap at castSig (s6b).
  (d) Raise K: about 2 kB for each unit (Q-S7-20 (d)), counters to 61 in
  s6b; a Q-S7-11 (a) STOP. RECOMMEND: (a). If the runtime goes over 24576,
  that is a Q-S7-11 (a) STOP. RULED: (a) (USER 2026-10-26).
- Q-S7-23 the proposal kind (s6c; Q-S7-18 (b) and (c)). (a) The 4 U256
  setters: `kind : U256` in the state, and kind 0 to 3 gives setCapN,
  setCapCN, setLockD or setRegD. `propose` refuses k > 3, so `enact`
  needs no TRAP arm. +464 bytes (s6c). Eval rows for each kind, and a
  chain row for kind 1 (setCapCN) after the second proposal. (b) All 7
  setters (Q-S7-18 (c)): the kit build refuses an Addr field in a `call`
  (s6c), so (b) also changes the call form for Addr and Flag fields and
  adds `pAddr` and `pFlag`. (c) Keep one setter (setCapN): `propose` sets
  only the value. RECOMMEND: (a). RULED: (a) (USER 2026-10-26).
- Q-S7-24 `openTally` (s6a). (a) Keep the open of T0 in `enact` (the s5
  form, one transaction). The PLAN records that the `openTally` of Q-S6-8
  (a) is this check. (b) A separate entry `openTally` writes yes and no
  to the state, and `enact` reads them: two transactions, two new state
  words and more rows. RECOMMEND: (a). RULED: (a) (USER 2026-10-26).
