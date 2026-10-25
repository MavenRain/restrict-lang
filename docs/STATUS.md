# restrict-lang status

> Write here: one paragraph. Say which milestone the build implements, and
> which milestone it does not complete yet.

## Implemented

> Write here: one item for each feature that works. Name the former (F1 to
> F15), the core type or the core operation.

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
  for each contract (O8). The old ops give the same bytes.
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

## Remaining M0 work

> Write here: one numbered item for each missing feature. Say what each item
> needs first.

1. <work item>.

## Known limits

> Write here: one item for each limit of the current build, with its cause
> (a fuel budget, a host limit, a stack size).

- <limit>.

## Internal boundaries

> Write here: one paragraph for each module group. Say which module holds
> which job, which tests check which tables, and which types a program
> cannot use.
