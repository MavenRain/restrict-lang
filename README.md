# restrict-lang

restrict-lang is a Cubical TT language for the transfer rules of tokenized
securities. A program states the compliance rules of one ERC-3643 token
(holder caps, country rules, lock-ups) as types. A rule is a decidable
proposition over the state and the move, and the `canTransfer` view is its
decision. Identity claims are ZK credentials: a holder proves that a trusted
issuer gave it a credential of one class, and the contract learns that
class only. A zero-knowledge, homomorphically encrypted, multi-party
self-referential DAO (the DAO of MavenRain/orbit-lang) governs each contract.
The only type constructors are cell monads and their duals. The host is
TinyCC. The compiler writes the EVM bytecode of an ERC-3643 compliance
contract.

restrict-lang comes from lang-template with the tcc-evm-contract host.

- `design/DESIGN.md`: the request and the domain design, verbatim. It is the
  only source of the core types and the core operations.
- `docs/PLAN.md`: the rulings, the reading of the type-former ruling, the
  minimal base signature, the readings of the design on Cubical TT, the
  laws, the kernel route, the contract, the slices, the open items and the
  questions.
- `SPEC.md`: the specification. Fill each section.
- `formers/FORMERS.md`: the type formers. `formers/tcc-evm-contract.md` gives their
  status on the tcc-evm-contract host.
- `probe/CAPABILITY.md`: the host probe.
- `docs/STATUS.md` and `docs/VALIDATION.md`: the status and the gate results.
- `docs/host/README.md`: how to build and test the host kit, and how to
  replace the sample domain in `domain/`.
