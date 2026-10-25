/* Host ballot regressions (intent-lang S9 b3; restrict-lang S6, Q-S6-7
   (a)): the encrypted ballots of Part D. Voters 0, 1 and 2 of the ring
   zkKey 0 .. 2 cast one-hot ballots (k 2: yes is slot 0, no is slot 1)
   under the election key of thresholdtool (n 3, t 2) for the proposal PID
   of the contract SELF. Each proof carries ctx = hash(hash(hash(ballotTag,
   I.x), I.y), pid) for the key image I of the voter (O34), and the ring
   signs the digest of the slot ciphertexts in the context word w =
   hash(self, pid) (blsag_sign_at, O15). With the argument `words` it prints
   the chain constants of examples/ballot.lang, one `name 0x<word>` per
   line. */
#include <stdio.h>
#include <string.h>

#include "front/blsag.h"
#include "front/elgamal.h"
#include "front/sigma.h"
#include "front/threshold.h"

#define N 3u
#define T 2u
#define K 2u
#define BITS 16u
/* "ballot" and "digest" as big endian words. */
#define BALLOT_TAG 0x62616c6c6f74ull
#define DIGEST_TAG 0x646967657374ull
/* The contract word (0x..c0, the constant self of examples/restrict.lang)
   and the proposal id. */
#define SELF 0xc0ull
#define PID 1ull
/* The known answer of ballotCtx for voter 0: a recomputation would follow a
   change of the tag, this word does not. */
#define CTX0 "0x8a5fa4ee8b9368d730caf7b8c2f36f9b5271f71e4d63a8de27876da1a936f4e1"

/* One cast: the bLSAG words c_1, s_1 .. s_3, I.x, I.y over the digest, the
   ctx of I, the slots and the sum proof. */
typedef struct {
  U256 sig[N + 3u];
  U256 ctx;
  U256 digest;
  ElgCipher cts[K];
  SigOr slots[K];
  SigDleq sum;
} Ballot;

static void hex(char *out, size_t size, const U256 *w) {
  snprintf(out, size, "0x%016llx%016llx%016llx%016llx", (unsigned long long)w->limb[3], (unsigned long long)w->limb[2],
           (unsigned long long)w->limb[1], (unsigned long long)w->limb[0]);
}

static void word(const char *prefix, const char *name, const U256 *w) {
  char text[67];
  hex(text, sizeof text, w);
  printf("%s%s %s\n", prefix, name, text);
}

static void point(const char *prefix, const char *x, const char *y, const G1 *p) {
  U256 a;
  U256 b;
  g1_to_words(&a, &b, p);
  word(prefix, x, &a);
  word(prefix, y, &b);
}

/* ballotCtx: the hash chain from ballotTag over I.x, I.y and the proposal id. */
static void ballot_ctx(U256 *out, const U256 *ix, const U256 *iy, const U256 *pid) {
  u256_from_u64(out, BALLOT_TAG);
  thr_hash(out, out, ix);
  thr_hash(out, out, iy);
  thr_hash(out, out, pid);
}

/* ballotDigest: the hash chain from digestTag over C1.x, C1.y, C2.x, C2.y of
   slot 0, then of slot 1. */
static void ballot_digest(U256 *out, const ElgCipher *cts) {
  U256 w[4];
  uint32_t j;
  uint32_t i;
  u256_from_u64(out, DIGEST_TAG);
  for (j = 0; j < K; j++) {
    g1_to_words(&w[0], &w[1], &cts[j].c1);
    g1_to_words(&w[2], &w[3], &cts[j].c2);
    for (i = 0; i < 4u; i++)
      thr_hash(out, out, &w[i]);
  }
}

/* The ballot of VOTER for CHOICE. The key image does not depend on the
   message, so a first signature gives I, and so ctx, before the slots
   exist. Fixed entropy for reproducible vectors only, never a live ballot.
   1, or 0 when a step refuses. */
static int cast(Ballot *b, const G1 *ring, const G1 *pk, const U256 *pid, const U256 *w, uint32_t voter, uint32_t choice) {
  U256 x;
  U256 seed;
  blsag_key(&x, voter);
  blsag_key(&seed, 40u + voter);
  if (!blsag_sign_at(b->sig, ring, N, &x, w, pid))
    return 0;
  ballot_ctx(&b->ctx, &b->sig[N + 1u], &b->sig[N + 2u], pid);
  if (sig_onehot_prove(b->cts, b->slots, &b->sum, pk, K, choice, &seed, &b->ctx) != SIG_OK)
    return 0;
  ballot_digest(&b->digest, b->cts);
  return blsag_sign_at(b->sig, ring, N, &x, w, &b->digest);
}

/* The sum of slot J over the three ballots. */
static void slot_sum(ElgCipher *out, const Ballot *b, uint32_t j) {
  elg_add(out, &b[0].cts[j], &b[1].cts[j]);
  elg_add(out, out, &b[2].cts[j]);
}

/* The parts of the quorum {1, 2} for CT. */
static void quorum(ThrPart *parts, const ThrShare *shares, const ElgCipher *ct) {
  thr_partial(&parts[0], &shares[0], ct);
  thr_partial(&parts[1], &shares[1], ct);
}

static int fail(const char *name) {
  fprintf(stderr, "FAIL ballot %s\n", name);
  return 0;
}

static void slot_words(const char *prefix, const ElgCipher *ct, const SigOr *s) {
  point(prefix, "c1x", "c1y", &ct->c1);
  point(prefix, "c2x", "c2y", &ct->c2);
  point(prefix, "a0x", "a0y", &s->a0);
  point(prefix, "b0x", "b0y", &s->b0);
  point(prefix, "a1x", "a1y", &s->a1);
  point(prefix, "b1x", "b1y", &s->b1);
  word(prefix, "e0", &s->e0);
  word(prefix, "e1", &s->e1);
  word(prefix, "z0", &s->z0);
  word(prefix, "z1", &s->z1);
}

static void cipher_words(const char *prefix, const ElgCipher *ct) {
  point(prefix, "c1x", "c1y", &ct->c1);
  point(prefix, "c2x", "c2y", &ct->c2);
}

static void part_words(const char *prefix, const char *d, const char *a, const char *b, const char *z, const ThrPart *p) {
  char x[8];
  char y[8];
  snprintf(x, sizeof x, "%sx", d);
  snprintf(y, sizeof y, "%sy", d);
  point(prefix, x, y, &p->d);
  snprintf(x, sizeof x, "%sx", a);
  snprintf(y, sizeof y, "%sy", a);
  point(prefix, x, y, &p->a);
  snprintf(x, sizeof x, "%sx", b);
  snprintf(y, sizeof y, "%sy", b);
  point(prefix, x, y, &p->b);
  word(prefix, z, &p->z);
}

/* The opening of slot sum CT by the quorum {1, 2}: the sum, the two parts
   and K = l1 D1 + l2 D2. */
static void open_words(const char *prefix, const ThrShare *shares, const ElgCipher *ct, const U256 *l1, const U256 *l2) {
  ThrPart parts[2];
  G1 q1;
  G1 q2;
  quorum(parts, shares, ct);
  cipher_words(prefix, ct);
  part_words(prefix, "d1", "a1", "b1", "z1", &parts[0]);
  part_words(prefix, "d2", "a2", "b2", "z2", &parts[1]);
  g1_mul(&q1, &parts[0].d, l1);
  g1_mul(&q2, &parts[1].d, l2);
  g1_add(&q1, &q1, &q2);
  point(prefix, "kx", "ky", &q1);
}

static void words(const G1 *pk, const G1 *ring, const ThrShare *shares, const Ballot *b) {
  ElgCipher yes;
  ElgCipher no;
  ThrPart parts[2];
  U256 l1;
  U256 l2;
  slot_sum(&yes, b, 0u);
  slot_sum(&no, b, 1u);
  quorum(parts, shares, &yes);
  thr_lagrange(&l1, parts, 2u, 0u);
  thr_lagrange(&l2, parts, 2u, 1u);
  point("", "pkx", "pky", pk);
  point("", "p0x", "p0y", &ring[0]);
  point("", "p1x", "p1y", &ring[1]);
  point("", "p2x", "p2y", &ring[2]);
  point("", "k1x", "k1y", &shares[0].key);
  point("", "k2x", "k2y", &shares[1].key);
  word("", "b0ix", &b[0].sig[N + 1u]);
  word("", "b0iy", &b[0].sig[N + 2u]);
  word("", "b0ctx", &b[0].ctx);
  word("", "b0digest", &b[0].digest);
  word("", "b0c1", &b[0].sig[0]);
  word("", "b0s1", &b[0].sig[1]);
  word("", "b0s2", &b[0].sig[2]);
  word("", "b0s3", &b[0].sig[3]);
  slot_words("b0j0", &b[0].cts[0], &b[0].slots[0]);
  slot_words("b0j1", &b[0].cts[1], &b[0].slots[1]);
  point("b0sum", "ax", "ay", &b[0].sum.a);
  point("b0sum", "bx", "by", &b[0].sum.b);
  word("b0sum", "z", &b[0].sum.z);
  word("", "b1ix", &b[1].sig[N + 1u]);
  word("", "b1iy", &b[1].sig[N + 2u]);
  cipher_words("b1j0", &b[1].cts[0]);
  cipher_words("b1j1", &b[1].cts[1]);
  cipher_words("b2j0", &b[2].cts[0]);
  cipher_words("b2j1", &b[2].cts[1]);
  word("", "l1", &l1);
  word("", "l2", &l2);
  open_words("ty", shares, &yes, &l1, &l2);
  open_words("tn", shares, &no, &l1, &l2);
}

int main(int argc, char **argv) {
  static const uint32_t choice[3] = {0u, 0u, 1u};
  Ballot b[3];
  ThrShare shares[N];
  ThrPart parts[2];
  G1 ring[N];
  G1 keys[N];
  G1 pk;
  U256 sk;
  U256 seed;
  U256 pid;
  U256 self;
  U256 w;
  U256 other;
  U256 x;
  U256 copied;
  U256 tampered;
  ElgCipher yes;
  ElgCipher no;
  char text[67];
  uint64_t m_yes = 0;
  uint64_t m_no = 0;
  uint32_t v;
  int ok = 1;
  blsag_key(&sk, 5u);
  blsag_key(&seed, 17u);
  if (!thr_deal(shares, &pk, &sk, &seed, T, N)) {
    fputs("FAIL ballot: the deal refuses\n", stderr);
    return 1;
  }
  for (v = 0; v < N; v++) {
    blsag_key(&x, v);
    elg_public(&ring[v], &x);
    keys[v] = shares[v].key;
  }
  u256_from_u64(&pid, PID);
  u256_from_u64(&self, SELF);
  thr_hash(&w, &self, &pid);
  for (v = 0; v < 3u; v++)
    if (!cast(&b[v], ring, &pk, &pid, &w, v, choice[v])) {
      fprintf(stderr, "FAIL ballot: the cast of voter %u refuses\n", v);
      return 1;
    }
  if (argc == 2 && strcmp(argv[1], "words") == 0) {
    words(&pk, ring, shares, b);
    return 0;
  }
  /* The ctx binding: voter 0's ctx is the pinned word and the ballot
     verifies under it. */
  hex(text, sizeof text, &b[0].ctx);
  ok &= (strcmp(text, CTX0) == 0 && sig_onehot_verify(b[0].cts, b[0].slots, &b[0].sum, &pk, K, &b[0].ctx) == SIG_OK)
        || fail("ctx binding");
  /* The digest signature: each ring signature verifies over its own
     digest, and voter 0's signature over the digest of voter 1's slots
     does not. */
  ballot_digest(&tampered, b[1].cts);
  ok &= (blsag_verify_at(ring, N, &w, &b[0].digest, b[0].sig) == BLSAG_ACCEPT
         && blsag_verify_at(ring, N, &w, &b[1].digest, b[1].sig) == BLSAG_ACCEPT
         && blsag_verify_at(ring, N, &w, &b[2].digest, b[2].sig) == BLSAG_ACCEPT
         && blsag_verify_at(ring, N, &w, &tampered, b[0].sig) == BLSAG_REJECT)
        || fail("digest signature");
  /* A copy of voter 0's slots and proofs under voter 1's key image. */
  ballot_ctx(&copied, &b[1].sig[N + 1u], &b[1].sig[N + 2u], &pid);
  ok &= sig_onehot_verify(b[0].cts, b[0].slots, &b[0].sum, &pk, K, &copied) == SIG_BAD_SLOT || fail("copy under a second key image");
  /* Voter 0's ballot in a second proposal: the ctx and the context word
     change, so the slot proofs and the signature fail there. */
  u256_from_u64(&other, PID + 1u);
  ballot_ctx(&copied, &b[0].sig[N + 1u], &b[0].sig[N + 2u], &other);
  thr_hash(&other, &self, &other);
  ok &= (sig_onehot_verify(b[0].cts, b[0].slots, &b[0].sum, &pk, K, &copied) == SIG_BAD_SLOT
         && blsag_verify_at(ring, N, &other, &b[0].digest, b[0].sig) == BLSAG_REJECT)
        || fail("ballot in a second proposal");
  /* The tally: the quorum {1, 2} opens the slot sums to (2, 1). */
  slot_sum(&yes, b, 0u);
  slot_sum(&no, b, 1u);
  quorum(parts, shares, &yes);
  ok &= (thr_open(&m_yes, parts, 2u, keys, T, N, &yes, BITS) == THR_FOUND && m_yes == 2u) || fail("tally yes");
  quorum(parts, shares, &no);
  ok &= (thr_open(&m_no, parts, 2u, keys, T, N, &no, BITS) == THR_FOUND && m_no == 1u) || fail("tally no");
  if (!ok)
    return 1;
  puts("ballot regressions: passed");
  return 0;
}
