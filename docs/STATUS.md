# restrict-lang status

The build implements the M0 slices S0 to S8 of docs/PLAN.md section 9:
they are DONE. S8 (the mutants, SPEC, VALIDATION and the close) is CLOSED
(2026-10-27): s1 to s5 are DONE, and the plan is closed. The last gate is
the S8 s5 final gate (EXIT 0, 257 evals, 0 failures; docs/VALIDATION.md).

## Implemented

- S2 (kernel port): `src/`, `domain/`, `examples/`, `test/`, `gen/` and
  the Makefile of intent-lang ef5abe8 (by `git archive`), and the
  intent-lang text of SPEC.md, docs/host/README.md, docs/VALIDATION.md,
  formers/FORMERS.md, formers/tcc-evm-contract.md and probe/CAPABILITY.md.
  The code is the ef5abe8 code byte for byte. `examples/inventory.lang` and
  `test/check/domain-name.lang` of the seed are removed (ef5abe8 does not
  have them; intent-lang S2 and resolve-lang S2 removed them for the same
  cause). The gate gives the intent-lang S7 counts (docs/PLAN.md section
  9). Name changes in the intent-lang text: SPEC.md line 1 (the title),
  line 3 (the working name) and line 14 (the purpose) say restrict-lang;
  docs/host/README.md line 3 adds "restrict-lang S2 ports it from
  intent-lang ef5abe8". These stay: the provenance comments `(orbit-lang Sn
  ...)` and `(intent-lang Sn ...)`, the evidence paths
  `~/Documents/intent-lang-work/...` in docs/VALIDATION.md, test/secptool.c
  and test/precompile.sh, the DAO words (`Orbit`, `orbitProj`), the bLSAG
  domain tag "orbit" and docs/VALIDATION.md, which records the gates of
  orbit-lang and intent-lang. The port carries the features of intent-lang
  S3 to S7 (`REFUSE_CELL`, `cofamily`, sealed `Enc`, `Quorum` and `open`,
  `ZKProof`, the Sigma verifiers, `ecrecover`); the intent-lang
  docs/STATUS.md at ef5abe8 describes each one. No restrict-lang feature
  is in S2: `Move`, `step` and the hooks are S3.
- S3 (Part T): `examples/mirror.lang` gives `Move` (a Sum alias), the
  mirror state, `step`, the hooks `transferred`, `created` and `destroyed`
  with the L9 guard, the binding (`bindToken`, `unbindToken`,
  `isTokenBound`, `getTokenBound`) and the L6 laws by `refl` (16 paths).
  `test/run/mirror.script` shows L9: each hook from an address that is not
  the bound token reverts. The kernel does not change.
- S4 (Part R): the kit form `rules R S M T := r1 | ... | rk` (lexer
  `TOK_KW_RULES`, ast `DECL_RULES`, parser `parse_rules`, checker
  `check_rules`). The form elaborates to text and checks each generated
  def: the `Dec` helpers, a proposition and a `dec` term for each rule,
  their product `R`, `R.dec`, `R.bit` and the view `canTransfer` (L1). A
  rule that is not a `Flag` test gives `TYPE_MISMATCH` (O5). The checker
  now refuses a def past `def_cap` with `OOM` (before S4, nothing checked
  that cap). `examples/restrict.lang` is `examples/mirror.lang` with the
  four rule tests, one form and the event `Broken`, and 23 more `refl`
  paths (L1, rules-cap L3 and L6, rules-lock L4). `test/run/restrict.script`
  shows the lock-up and the holder cap, `Broken` on a forced move, and the
  mint bypass.
- S5 (Part C): the kit ops `zkHpAt`, `zkSignAt` and `zkVerifyAt`
  (`src/front/blsag.c`, `core.h`, `check.c`, `eval.c`). The context word
  goes into the hash to curve, so one credential key gives one key image
  for each contract (O8, CLOSED). The old ops give the same bytes.
  `test/blsagtool.c` has the context rows. `examples/restrict.lang` adds
  the registry state (`used`, `clsOf`, `expires`, the ring slot maps), the
  class map `cls`, the entries `issue` and `register`, the view
  `isVerified` and `clsCode := clsOf`, and 26 more `refl` paths (L2, L7,
  L8, the class rule of `register`). `test/run/restrict.script` shows
  `issue`, `register`, a second `register` with a used key image (revert)
  and the end of a registration.
- S6 (the DAO over the rules, Q-S6-1..8 (a)): the port of intent-lang S9
  (`examples/tally.lang`, `examples/ballot.lang`, `test/ballottool.c`,
  `test/check/tally-leak.lang`, 15 eval rows and 9 precompile steps). The
  ballot ring signs in the context word hash(selfWord, pid) (Q-S6-7 (a)),
  and `test/ballottool.c` has the row "ballot in a second proposal".
  `examples/restrict.lang` adds Part G: the state words `pCapN`, `pCapCN`,
  `pLockD` and `pRegD`, the issuer map `issuers` and the class pass set
  `passCls`, which the rule tests, `issue` and `regSet` read; the setters
  and 21 more `refl` paths. `examples/charter.lang` (guest mode) adds the
  charter law (`active`), the yes or no rule of the swap group and the
  regime rows (AD, and the contrast row SI). In `test/run/restrict.out`,
  only the last line changes: the state shows the six Part G words. No
  src change.
- S7 (the contract, Q-S7-1 to Q-S7-28): the port of intent-lang S8 and
  S10 (the `Env.block` prelude, `examples/blocks.lang`,
  `examples/daokit.lang`, `test/dao.sh`). The rules form builds
  `allowed.bit` from the rule bits (Q-S7-2 (a)). The kit op `toNat : U256
  -> Nat` (Nat is an ABI `uint64`): eval traps above 2^64 - 1, and the
  lowering reverts. The `Env` field `self` lowers to ADDRESS, and the
  constant `self` is now `selfAddr`. An open `zkHpAt` is an opaque term in
  eval. The internal op `OP_MODEXP` (precompile 0x05) and the H_p loop
  `lower_hp` with K = 8 tries (`RESTRICT_HP_TRIES`) give `zkHpAt` on the
  chain. `examples/restrictkit.lang` is the deployable compliance
  contract: the hooks, the binding, `canTransfer`, `issue` (with the
  counter hc), `register`, `isVerified`, the init field `dao` and 7 setter
  entries with the check `fromDao`. `examples/restrictdao.lang` is its
  linked DAO: `propose` (the pid, the counter bounds before each `hpAt`,
  the kind), the casts `castSig`, `castSlot` and `castSeal`, `enact` (it
  opens the tally and, on a strict yes majority, calls one of the four
  numeric setters by kind) and the views `pidNow` and `kindNow`. The kit
  CALL form gives the call. `examples/natkit.lang` has the `toNat` chain
  rows. The asmtool mode `token` is the test token. `test/restrict.sh` and
  `test/dao.sh` have the chain, ABI, size and gas rows. The USER fix
  525e855: `proposalValueOk` limits the durations (kinds 2 and 3) to
  2^64 - 1.
- S8 (the close, CLOSED): s1 the survey and Q-S8-1 to Q-S8-7; s2 the
  mutants N1 to N5 (L5, L11, L12, `proposalValueOk` x2), all KILLED, thus
  each law site of docs/PLAN.md section 5 has a mutant (S3 to S8: 80
  KILLED, 2 equivalent, 0 SURVIVED); s3 SPEC.md, with the corrections of
  the USER review (155d9e0); s4 docs/VALIDATION.md and this file.
  docs/VALIDATION.md now records only the restrict-lang gates: the
  inherited orbit-lang and intent-lang text goes (Q-S8-4 (a)). s5: the
  final serial gate (EXIT 0, byte for byte the s4 step0 log) and the close
  (O6 and O8 CLOSED, Q-S8-7 (a)). S8 does not change src.

## Remaining M0 work

1. O17: `examples/restrict.lang` gives the class map `cls` by hand (S1 =
   {840} gives class 1, the other countries give class 0). First: a
   change to `check_rules`, so that the rules form computes `cls` from the
   sets of its rules (Q-S5-3 (b)).
2. O18: a State argument to a def that holds `zkVerifyAt` adds about 6.3
   KB of runtime, also when the body does not read it. First: a probe of
   the cause in the lowering (S8 does not probe it, Q-S8-6 (b)).

## Known limits

- The restrictdao runtime is 23909 bytes of 24576 (EIP-170): 667 bytes
  of room. Cause: the ballot casts, the tally open in `enact` and the H_p
  loops are in one contract. The ballot entries do not fit in restrictkit
  (S7 s4 probe: `castSig` alone is about 9.2 kB).
- A credential issuer ring has 2 points per class; the DAO ballot ring
  has 3 points. Each ring point needs an H_p counter hc <= 7 for its
  context. Cause: the H_p loop runs K = 8 tries on the chain
  (`RESTRICT_HP_TRIES`), and a key with no point below counter 8 traps.
- A duration (`setLockD`, `setRegD`) is at most 2^64 - 1. Cause: Nat is
  an ABI `uint64` (Q-S7-4), and `proposalValueOk` refuses a larger value.
- A proposal lapses at the next `propose`. Cause: restrictdao keeps the
  pid and the kind of one proposal (`pidNow`, `kindNow`).
- The chain rows test the test token only (O7, `asmtool token`).
- The contract does not serve `investorCountry` (O12). Cause: a
  credential discloses the class only (Q5 (a)). A token or a tool that
  calls it fails.
- The USER review of S8 s3 (SPEC section 7, PLAN O10): the linked DAO
  votes only on the four numeric parameters. It has no vote or call path
  for `setIssuer`, `setPass` or `setDecided`, and it does not execute
  charter or rule-set amendments. `isVerified` checks only the stored
  wallet expiry, thus a ring change or a class change does not invalidate
  a registration. The kit build of `examples/restrict.lang` gives
  `REFUSE_LOWER` at `canTransfer`.
- formers/tcc-evm-contract.md gives eval OPAQUE for `ecrecover`, `ecAdd`
  and `ecMul`, but rule R17 makes a closed application compute in `langc
  eval` (SPEC section 3, docs/VALIDATION.md "Known limits").

## Internal boundaries

The parser (src/front): `lexer.c`, `parser.c` and `ast.h` read the text
into the AST, with the kit forms (`rules`, the CALL form).

The core (src/front): `base.c` holds the base signature, `check.c` the
type checker and its refusal codes, `eval.c` the evaluator, the conversion
test, quote and the printer, and `core.h` the core terms. `front.c` loads
a program. `contract.c` holds the kit prelude, which `front_load` reads
after domain/domain.lang as trusted text. A guest program cannot use the kit forms: the 23 kit-only rows
give `REFUSE_KIT`.

The host crypto (src/front): `u256.c` (U256 and Addr), `bn254.c` (the
BN254 field and G1), `secp256k1.c` (the ecrecover recovery), `blsag.c`
(bLSAG with the context word), and `elgamal.c`, `threshold.c` and
`sigma.c` (exponential ElGamal, the threshold opening and the Sigma
verifiers).

The writer (src/front): `writer.c` gives `langc contract`, the kit text of
the DAO in a checked guest program.

The back end (src): `lower.c` lowers a checked kit program to EVM code
(`langc build`), `evm.c` holds the EVM back end and the ABI selectors,
`asm.c` the assembler and `keccak.c` Keccak-256. `main.c` is the `langc`
command line (exit 0: ok, exit 1: refused, exit 2: usage or IO).

The test tools (test/*.c, built with tcc and checked with clang):
asmtool, ballottool, blsagtool, buildtool, elgamaltool, emittool, evmtool,
fronttool, lowertool, pathtool, runtool, secptool, sigmatool, slottool,
thresholdtool and writertool. The row directories are test/parse,
test/check, test/eval, test/prove, test/run, test/lower and test/contract.

The gate scripts (test/*.sh): `make -B check` runs gate.sh, run.sh,
asm.sh, build.sh, dispatch.sh, evm.sh, precompile.sh, mock.sh, dao.sh,
restrict.sh, diff.sh and review.sh in series.
Each script prints its count lines and a gate line with 0 failures.
