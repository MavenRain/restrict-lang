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
