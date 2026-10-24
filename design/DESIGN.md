# restrict-lang domain design

> Paste the domain design below the line, verbatim. Do not edit it.

This file is the only source of the core types and the core operations of
restrict-lang. `SPEC.md` sections 5 and 6 cite its sections. Do not add a core
type or a core operation that this file does not give.

When the design changes, paste the new version. Then record the change as an
open item in `SPEC.md` section 9.

---

## The request (verbatim, 2026-10-24)

I want to write a programming language with the following characteristics:

For type constructors/higher-kinded types, admit the following: cell monads and their duals in a locally presentable locally cartesian closed \((\infty,1)\)-category, as represented computationally in Cubical Type Theory

For base types and operations, admit the minimum required to satisfy the following description: 

[the pasted design below]

A UAT-respecting ZK FHE MPC self-referential-DAO should govern all contracts, and the host language shall be TinyCC.

## The pasted design (verbatim)

  3. A transfer-restriction language for tokenized assets

  - Activity:
    - On Sept 17, the SEC exemption let permissioned on-chain venues trade
      tokenized US stocks.
    - On Sept 1, the SEC proposed letting transfer agents keep records on chain.
    - Today's Federal Register carries the OCC's proposed rules for stablecoin
      issuers under the GENIUS Act, the 2025 US stablecoin law.
  - The language: ERC-3643 is the token standard most used for permissioned
    securities. Today its compliance rules are hand-written Solidity: holder
    caps, country rules, lock-ups. The language would state those rules as types
    and identity claims as ZK credentials, then compile to an ERC-3643
    compliance contract.
