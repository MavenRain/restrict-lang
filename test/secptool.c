/* Host ecrecover regressions (slice S7 b4, survey section 6): the 0x01 rules
   of front/secp256k1.c. Each vector was confirmed with a direct `evm run` to
   0x..01 (2026-10-23, evm 1.14.12; ~/Documents/intent-lang-work/S7-ec-confirm.sh). */
#include <stdio.h>

#include "front/secp256k1.h"

/* The word of HEX (64 digits or fewer, no prefix). */
static U256 word(const char *hex) {
  U256 x;
  u256_from_u64(&x, 0);
  for (; *hex != '\0'; hex++)
    u256_scale_add(&x, 16u, (uint32_t)(*hex <= '9' ? *hex - '0' : *hex - 'a' + 10));
  return x;
}

static int check(const char *name, const U256 *h, uint64_t v, const U256 *r, const U256 *s, const U256 *want) {
  U256 out;
  U256 vw;
  u256_from_u64(&vw, v);
  secp_recover(&out, h, &vw, r, s);
  if (u256_cmp(&out, want) == 0)
    return 0;
  fprintf(stderr, "FAIL ecrecover %s: %016llx%016llx%016llx\n", name, (unsigned long long)out.limb[2],
          (unsigned long long)out.limb[1], (unsigned long long)out.limb[0]);
  return 1;
}

int main(void) {
  /* go-ethereum core/vm/testdata/precompiles/ecRecover.json, CallEcrecover0:
     r is the hash word. */
  U256 h = word("38d18acb67d25c8bb9942764b62f18e17054f66a817bd4295423adf9ed98873e");
  U256 s = word("789d1dd423d25f0772d2748d60f7e4b81bb14d086eba8e8e8efb6dcff8a4ae02");
  U256 addr = word("ceaccac640adf55b2028469bd36ba501f28b699d");
  U256 n = word("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141");
  U256 h1 = word("38d18acb67d25c8bb9942764b62f18e17054f66a817bd4295423adf9ed98873f");
  U256 other = word("89eea7f8bed00e8eb90e9fb33ee264640a9cb429");
  U256 zero;
  U256 high;
  int fail = 0;
  u256_from_u64(&zero, 0);
  u256_sub(&high, &n, &s);
  fail += check("go-ethereum vector", &h, 27, &h, &s, &addr);
  fail += check("v 29", &h, 29, &h, &s, &zero);
  fail += check("r 0", &h, 27, &zero, &s, &zero);
  fail += check("s n", &h, 27, &h, &n, &zero);
  /* No EIP-2 rule in 0x01: (r, n - s, the other v: 28 for 27, 27 for 28)
     is the same signer. */
  fail += check("high s", &h, 28, &h, &high, &addr);
  fail += check("wrong h", &h1, 27, &h, &s, &other);
  if (fail != 0)
    return 1;
  puts("ecrecover regressions: passed");
  return 0;
}
