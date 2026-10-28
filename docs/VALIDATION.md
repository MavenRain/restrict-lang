# Validation

Date: 2026-10-27. tcc: 0.9.28rc. evm (go-ethereum): 1.14.12. Base: HEAD
e6082c4 (the USER S8 s4 commit). S8 is CLOSED, and the plan is closed.
This file is final: each count, size row, gas row and chain step comes
from the S8 s5 final gate.

The last gate is the S8 s5 final gate
(`~/Documents/restrict-lang-S8-s5-final-gate.log`, 126 lines, EXIT 0). It
is byte for byte the S8 s1, s2, s3 and s4 step0 logs. `make -B check` builds
`langc` and the test tools with tcc, runs the clang `-Wall -Wextra
-Wswitch-enum -Werror` check, and runs the gate scripts. It runs 60
examples, 19 parse refusals, 193 check refusals (23 of them are kit-only
rows: `langc check` gives `REFUSE_KIT`, and `langc --kit check` accepts
them), 257 evals, 2 proves, 7 contract rows (2 written, 5 refused), 8 ring
rows (6 built, 2 refused), 28 differential guest evals, 11 runs, 14
differential host runs, 15 run refusals, 8 asmtool checks, 3 builds, 17
lower refusals, 34 build checks, 20 dispatch checks, 69 evm steps, 14
differential EVM rows, 156 precompile steps, 13 mock rows, the dao size,
gas and chain rows (89 chain steps), the restrict size and ABI rows (9 EIP
selectors), 40 restrict steps, 15 diff rows, 24 emit regressions and the
review, domain, bLSAG, elgamal, threshold, sigma, ballot, dao, ecrecover,
path, run fuel, writer, build output, lower and evm hashing regressions,
with 0 failures.

The kernel base is intent-lang ef5abe8: S2 ports it byte for byte (`git
archive`). The gates of orbit-lang and intent-lang up to ef5abe8 are in
docs/VALIDATION.md of intent-lang at ef5abe8. This file records only the
gates of restrict-lang.

## S0: the kit

S0 generates the repo from lang-template with the kit tcc-evm-contract,
and adds DESIGN verbatim, docs/PLAN.md and the README. The gate
(`~/Documents/restrict-lang-S0-gate.log`, EXIT 0): 19 examples, 13 parse
refusals, 57 check refusals, 55 evals, 5 runs, 10 run refusals, 8 asmtool
checks, 3 builds, 11 lower refusals, 28 build checks, 20 dispatch checks,
43 evm steps, 13 mock rows and 15 diff rows, 0 failures.

## S1: the rulings

The USER rules Q1 to Q14. S1 changes only docs/PLAN.md. The gate
(`~/Documents/restrict-lang-S1-gate.log`, EXIT 0) gives the S0 counts (19
examples, 55 evals), 0 failures.

## S2: the kernel port

S2 ports intent-lang ef5abe8 (PLAN section 6). The code is the ef5abe8
code byte for byte. The gate (`~/Documents/restrict-lang-S2-gate.log`,
EXIT 0) is byte for byte the intent-lang S7 log: 49 examples, 19 parse
refusals, 186 check refusals (22 kit-only), 188 evals, 2 proves,
contracts 2 written and 5 refused, rings 6 built and 2 refused, 28 guest
and 14 host differential rows, 5 runs, 10 run refusals, 8 asmtool checks,
3 builds, 16 lower refusals, 33 build checks, 20 dispatch checks, 43 evm
steps, 14 differential EVM rows, 143 precompile steps, 13 mock rows, 15
diff rows, 24 emit regressions and the 13 "regressions: passed" lines, 0
failures.

## S3: Part T (2026-10-24)

`examples/mirror.lang` adds `Move`, the mirror state, `step`, the hooks
with the L9 guard and the binding, with 16 L6 paths by `refl`.
`test/run/mirror.script` has 17 rows (L9). The kernel does not change.
The gate (`~/Documents/restrict-lang-S3-gate.log`, EXIT 0): examples
49 -> 50 and runs 5 -> 6. The other lines are the S2 lines. Mutants: 7
(L6 x5, L9 x2), 7 KILLED.

## S4: Part R (2026-10-24)

The kit form `rules` (five src/front files) elaborates to the `Dec`
helpers, one proposition and one `dec` term for each rule, `R`, `R.dec`,
`R.bit` and the view `canTransfer` (L1). `examples/restrict.lang` adds
the four rule tests, one form, the event `Broken` and 23 `refl` paths (L1,
L3, L4). `test/check/rules-no-dec.lang` gives `TYPE_MISMATCH` (O5).
`test/run/restrict.script` has 14 rows. The gate
(`~/Documents/restrict-lang-S4-gate.log`, EXIT 0): examples 50 -> 51,
check refusals 186 -> 187, runs 6 -> 7. Mutants: 7, 6 KILLED, 1
equivalent (PLAN section 3.3, S4 notes).

## S5: Part C (2026-10-25)

The kit ops `zkHpAt`, `zkSignAt` and `zkVerifyAt` put the context word in
the hash to curve. Thus one credential key gives one key image for each
contract (O8). `examples/restrict.lang` adds the registry state, `issue`,
`register`, `isVerified` and 26 `refl` paths (L2, L7, L8).
`test/run/restrict.script` gets 9 rows, and `test/blsagtool.c` gets the
context rows. The gate (`~/Documents/restrict-lang-S5-gate.log`, EXIT 0)
is byte for byte the S5 step0 log: no counter changes. Mutants: 6, 6
KILLED.

## S6: the DAO over the rules (2026-10-25)

S6 ports intent-lang 3df9d96 (`examples/tally.lang`,
`examples/ballot.lang`, `test/ballottool.c`) with the ballot context word
hash(selfWord, pid). `examples/restrict.lang` adds the `Params` words, the
issuer map, the class pass set and the setters (21 `refl` paths).
`examples/charter.lang` adds the charter law and the regime rows. The gate
(`~/Documents/restrict-lang-S6-gate.log`, EXIT 0): examples 51 -> 54,
check refusals 187 -> 188, evals 188 -> 203, precompile steps 143 -> 152,
and the `ballottool` build, check-clang and regression lines. Mutants: 8,
8 KILLED.

## S7: the contract (2026-10-25 to 2026-10-27)

- s1: the probes p1 to p7. Docs only.
- s2 (`~/Documents/restrict-lang-S7-s2-gate.log`): the port of intent-lang
  S8 and S10 (the `Env.block` prelude, `examples/blocks.lang`,
  `examples/daokit.lang`, `test/dao.sh`), `allowed.bit` from the rule
  bits, the kit op `toNat` and the `Env` field `self`. Examples 54 -> 57,
  evals 203 -> 221, runs 7 -> 10, run refusals 10 -> 15, evm steps
  43 -> 62, and the new dao lines (size 16702/16737, chain 33 steps).
  Mutants: 8, 8 KILLED.
- s3 (`~/Documents/restrict-lang-S7-s3-gate.log`): `OP_MODEXP`, the H_p
  loop `lower_hp` (K = 8), `examples/restrictkit.lang` and
  `test/restrict.sh` (8 steps). Examples 57 -> 58, lower refusals
  16 -> 17, build checks 33 -> 34, precompile steps 152 -> 156. The
  restrictkit runtime is 15490 bytes. Mutants: 8, 7 KILLED, 1 equivalent
  (`u256Le hc 8u`).
- s4 (`~/Documents/restrict-lang-S7-s4-gate.log`): the init field `dao`,
  7 setter entries with the check `fromDao`, `examples/natkit.lang` (the
  `toNat` chain rows), the test token (`asmtool token`) and the ABI row (9
  EIP selectors). Examples 58 -> 59, runs 10 -> 11, evm steps 62 -> 69,
  restrict steps 8 -> 40, restrictkit 16050/16177 bytes. Mutants: 14, 14
  KILLED.
- s5 (`~/Documents/restrict-lang-S7-s5-gate.log`): the kit CALL form,
  `examples/restrictdao.lang` (its `enact` calls `setCapN`) and the
  `test/dao.sh` part 2 chain rows. Examples 59 -> 60, check refusals
  188 -> 193, kit-only rows 22 -> 23, evals 221 -> 235, the rdao size row
  (19632/19667), dao chain 33 -> 63 steps. Mutants: 9, 9 KILLED.
- s6: the survey s6a to s6c. Docs only.
- s7 (`~/Documents/restrict-lang-S7-s7-gate.log`): `propose` with the pid,
  the counter bounds and the kind; `enact` by kind; the views `pidNow`
  and `kindNow`; `sigOk` takes the word w (rdao runtime 30097 -> 23839
  bytes). Evals 235 -> 249, rdao 23839/23879, the gas row `rdao propose
  124712`, dao chain 63 -> 89 steps. Mutants: 10, 10 KILLED. S7 CLOSED.
- The USER fix (525e855, the S8 base): `proposalValueOk` limits the
  durations of kinds 2 and 3 to 2^64 - 1. Evals 249 -> 257, rdao
  23909/23949, `rdao propose` 124712 -> 124761. The chain stays at 89
  steps. The log is `~/Documents/restrict-lang-S8-s1-step0-gate.log`.

## S8: the close (2026-10-27, CLOSED)

Each S8 gate log is byte for byte the s1 step0 log (126 lines, EXIT 0).

- s1 (`~/Documents/restrict-lang-S8-s1-step0-gate.log`): the survey and
  Q-S8-1 to Q-S8-7. Docs only.
- s2 (`~/Documents/restrict-lang-S8-s2-step0-gate.log`): the mutants N1
  to N5, 5 KILLED, no new test row. Docs only.
- s3 (`~/Documents/restrict-lang-S8-s3-step0-gate.log`): SPEC.md. The
  USER review (155d9e0) corrects five SPEC claims and records the
  implementation limits of "Known limits" below. Docs only.
- s4 (`~/Documents/restrict-lang-S8-s4-step0-gate.log`): this file and
  docs/STATUS.md. Docs only. The USER s4 commit (e6082c4) corrects the
  ring sizes of "Known limits" in docs/STATUS.md.
- s5 (`~/Documents/restrict-lang-S8-s5-final-gate.log`): the final serial
  gate and the close. O6 and O8 are CLOSED (Q-S8-7 (a)). Docs only.

## Contract sizes

The limits are 24576 bytes of runtime (EIP-170) and 49152 bytes of
initcode (EIP-3860). Source: the size rows of the gate log
(`test/dao.sh`, `test/restrict.sh`).

| Contract | Source | Runtime (bytes) | Initcode (bytes) | Runtime room |
|---|---|---|---|---|
| restrictdao | `examples/restrictdao.lang` | 23909 | 23949 | 667 |
| dao | `examples/daokit.lang` | 16702 | 16737 | 7874 |
| restrictkit | `examples/restrictkit.lang` | 16050 | 16177 | 8526 |
| natkit | `examples/natkit.lang` | 138 | 157 | 24438 |

The guest writer `langc contract` has 7 rows: 2 written and 5 refused.

## Gas

Source: the `dao gas rows` line of the gate log (`test/dao.sh`).

| Row | Gas |
|---|---|
| dao deploy | 3410413 |
| dao castSig | 291276 |
| dao castSlot | 96024 |
| dao castSeal, first | 283298 |
| dao castSeal, later | 129398 |
| dao enact | 117808 |
| rdao propose | 124761 |
| rdao enact | 130578 |

## Chain steps

| Script | Steps | Rows |
|---|---|---|
| `test/restrict.sh` | 40 | restrictkit: the H_p rows (S7 s3, 8), the setter rows (17) and the token rows (15) |
| `test/dao.sh` | 89 | part 1: the dao of `examples/daokit.lang` (33); part 2: restrictdao linked to restrictkit (56; S7 s5 and s7) |
| `test/evm.sh` | 69 | the evm steps |
| `test/precompile.sh` | 156 | the precompile steps |

## Mutants

| Slice | Mutants | KILLED | Equivalent | SURVIVED |
|---|---|---|---|---|
| S3 | 7 (L6 x5, L9 x2) | 7 | 0 | 0 |
| S4 | 7 (L1, L3 x2, L4, O5, `Broken`, `RULES_HELPERS 9u`) | 6 | 1 | 0 |
| S5 | 6 (L2, L7, L8, the key image context, expiry, the class rule) | 6 | 0 | 0 |
| S6 | 8 | 8 | 0 | 0 |
| S7 s2 | 8 | 8 | 0 | 0 |
| S7 s3 | 8 | 7 | 1 (`u256Le hc 8u`) | 0 |
| S7 s4 | 14 | 14 | 0 | 0 |
| S7 s5 | 9 | 9 | 0 | 0 |
| S7 s7 | 10 | 10 | 0 | 0 |
| S8 s2 | 5 (N1 L5, N2 L11, N3 L12, N4 and N5 `proposalValueOk`) | 5 | 0 | 0 |
| Sum | 82 | 80 | 2 | 0 |

The S8 s2 killers: N1, the mirror rows of `test/restrict.sh`; N2, the 9
`REFUSE_LAW` rows of the check list; N3, the examples step
(`examples/dao.lang`, `PATH_END`); N4, the eval rows proposeLockOver and
proposeRegOver; N5, the eval rows proposeLockOver and proposeLockHigh.
Each law site of PLAN section 5 has a mutant.

## Known limits

- The ec gap. formers/tcc-evm-contract.md gives eval OPAQUE for
  `ecrecover`, `ecAdd` and `ecMul`. Rule R17 (from the port) makes a
  closed application of these ops compute in `langc eval`. SPEC section 3
  states the gap. S8 s4 does not change the formers file.
- The USER review of S8 s3 (155d9e0) records these implementation limits
  (SPEC section 7, PLAN O10):
  - The linked DAO votes only on kinds 0 to 3 (`setCapN`, `setCapCN`,
    `setLockD`, `setRegD`). It has no vote or call path for `setIssuer`,
    `setPass` or `setDecided`. Thus the issuer list, the class passes and
    the binding decision keep their initial values.
  - The linked DAO does not execute charter or rule-set amendments.
    `examples/charter.lang` checks their laws.
  - `isVerified` checks only the stored wallet expiry. A ring change or a
    class change does not invalidate a registration (O10).
  - The kit build of `examples/restrict.lang` gives `REFUSE_LOWER` at
    `canTransfer`. The deployable programs are restrictkit and
    restrictdao.
- The chain rows test the test token only (O7). The other limits are in
  docs/STATUS.md "Known limits".
