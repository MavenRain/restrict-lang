#!/bin/sh
# The restrict chain gate (S7 s3, Q-S7-14 (e1)). Deploy examples/restrictkit.lang,
# then run the issue and register calls of the kit rows on the chain, at
# TIMESTAMP 1. issue takes five words (c i kx ky hc): hc is the H_p counter of
# the key at the contract word wC (hpIdx: zkKey 13 0u, zkKey 2 5u, zkKey 18 7u),
# and the MODEXP loop of register computes H_p of each ring point. The words
# are `langc --kit eval examples/restrictkit.lang` of k0, k1, k2, kR, sigD and
# img0. S7 s4 adds the setter rows, the test token rows, the ABI row and the
# size rows. It needs evm (go-ethereum), bc, od, build/slottool and
# build/asmtool (the test token). Run it from the kit root.
set -u
fail=0
steps=0
tmp=${TMPDIR:-/tmp}/langc-restrict.$$
mkdir -p "$tmp"
. test/evmchain.sh

prog=examples/restrictkit.lang
issuer=0x00000000000000000000000000000000000000e1
dave=0x00000000000000000000000000000000000000dd
dao=0x00000000000000000000000000000000000000da
alice=0x00000000000000000000000000000000000000aa
bob=0x00000000000000000000000000000000000000bb
carol=0x00000000000000000000000000000000000000cc
testToken=0x00000000000000000000000000000000000000ee

# call WANT CALLER NAME ARGS...: one step of the entry NAME with ARGS from
# CALLER. The result must equal WANT: ok, revert or trap. An entry changes the
# storage of the next step.
call() {
  _want=$1 _caller=$2 _name=$3
  shift 3
  steps=$((steps + 1))
  _input=$(input "$prog" "$_name" "$@")
  if ! step 1 1u "$_caller" "$_input"; then
    echo "FAIL restrict $_name: evm: $(head -n 1 "$tmp/dump")"
    fail=$((fail + 1))
    return
  fi
  if [ "$result" != "$_want" ]; then
    echo "FAIL restrict $_name: want $_want, got $result"
    fail=$((fail + 1))
  fi
}

# The test token (S7 s4, Q-S7-7 (a)): `build/asmtool token` at testToken, with
# restrictkit at the receiver. tcall WANT CALLER SEL WORDS...: one call of the
# token from CALLER with the selector SEL and the words WORDS (hex, no 0x), at
# TIMESTAMP 1; the token calls restrictkit. The result must equal WANT: ok,
# revert or `out HEX`. tmp/raw gets the restrictkit storage after the call,
# tmp/traw the token storage (an account key of the dump has 40 hex digits).
tcall() {
  _want=$1 _caller=$2 _sel=$3 _input=$3
  shift 3
  steps=$((steps + 1))
  for _w in "$@"; do _input=$_input$(pad "$_w"); done
  _st=$(awk '{ printf "%s\"0x%s\":\"0x%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$tmp/raw")
  _tt=$(awk '{ printf "%s\"0x%s\":\"0x%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$tmp/traw")
  genesis 1 "\"0x$receiver\":{\"balance\":\"0x0\",\"code\":\"0x$(cat "$tmp/code")\",\"storage\":{$_st}},\"$testToken\":{\"balance\":\"0x0\",\"code\":\"0x$(cat "$tmp/token")\",\"storage\":{$_tt}}"
  if ! evm run --prestate "$tmp/pre.json" --receiver "$testToken" --sender "$_caller" --input "$_input" \
    --dump >"$tmp/dump" 2>&1; then
    echo "FAIL restrict token $_sel (step $steps): evm: $(head -n 1 "$tmp/dump")"
    fail=$((fail + 1))
    return
  fi
  result=$(outcome "$tmp/dump")
  : >"$tmp/raw"
  : >"$tmp/traw"
  awk -F'"' -v r="0x$receiver" -v raw="$tmp/raw" -v traw="$tmp/traw" '
    NF >= 3 && length($2) == 42 && substr($2, 1, 2) == "0x" { a = tolower($2); next }
    NF >= 5 && length($2) == 66 && substr($2, 1, 2) == "0x" { print substr($2, 3), $4 >>(a == r ? raw : traw) }' "$tmp/dump"
  if [ "$result" != "$_want" ]; then
    echo "FAIL restrict token $_sel (step $steps): want $_want, got $result"
    fail=$((fail + 1))
  fi
}

k0='21833434209372390497220927343386216379657858864776266497325703093684392769302u 12874932415463263904695430394231571432968070260170557503096856560916129065301u'
k1='4511345014148855701978391702360003017939601606553168540311183374506603172252u 2508286508073671329325533888106374632645724638115976139622841388553619003967u'
k2='3241757377183167949032929831004361942501854994991174814434473960588699604752u 19891792280420720065097129249052343745268451585003762884805248180858213417800u'
kR='21576012433999932920735124394921461927089194087037988485273198605798414207857u 16628399031297167549133710224180735038020239690938175651395637673254031640298u'
sigD='31307969554993834751326573480168111330876001216405783724241879292908322329345u 4428006176277401799871890354594461903464748744454597872821702812426687184812u 1914194454328571386446334591130197642291842960735148245250999713293691353312u 5821018809950802345560104498997628436107942906226935339058014206824858009089u 9823664896109694316618777372473275169115683108140959571229177490073054481499u'

if ! deploy "$prog"; then
  echo "FAIL restrict deploy: $(head -n 1 "$tmp/dump")"
  fail=$((fail + 1))
else
  # issueSets, issueBadCounter: k0 (counter 0) into slot 0 of class 1; k1
  # (counter 5) with hc 0u reverts, with hc 5u it is slot 1 of class 1.
  call ok "$issuer" issue 1u 0u $k0 0u
  call revert "$issuer" issue 1u 1u $k1 0u
  call ok "$issuer" issue 1u 1u $k1 5u
  # issueMaxCounter: k2 (counter 7, the max) into slot 0 of class 0.
  call ok "$issuer" issue 0u 0u $k2 7u
  # issueNoPoint: zkKey 1 G has no counter below K = 8, so the H_p loop of
  # hpAt stops with the Trap() selector; issueNotIssuer.
  call trap "$issuer" issue 1u 0u $kR 7u
  call revert "$dave" issue 1u 0u $k0 0u
  # regDave: the ring (k0, k1) of class 1 at wC, by the MODEXP loop; L7: the
  # same key image a second time reverts.
  call ok "$dave" register 1u $sigD
  call revert "$dave" register 1u $sigD
  # The setters (S7 s4, Q-S7-15 (a)): the dao caller only, another caller
  # reverts. A Nat word above 2^64 - 1 stops at the TRAP arm of toNat. After
  # setIssuer, dave can issue (k1, counter 5, into slot 1 of class 0).
  call revert "$dave" setCapN 5u
  call ok "$dao" setCapN 5u
  call revert "$dave" setCapCN 6u
  call ok "$dao" setCapCN 6u
  call revert "$dave" setLockD 3600u
  call ok "$dao" setLockD 3600u
  call trap "$dao" setLockD 18446744073709551616u
  call revert "$dave" setRegD 7200u
  call ok "$dao" setRegD 7200u
  call trap "$dao" setRegD 18446744073709551616u
  call revert "$dave" setIssuer $dave flagYes
  call ok "$dao" setIssuer $dave flagYes
  call ok "$dave" issue 0u 1u $k1 5u
  call revert "$dave" setPass 1u flagYes
  call ok "$dao" setPass 1u flagYes
  call revert "$dave" setDecided $dave
  call ok "$dao" setDecided $testToken
  # The test token rows (S7 s4, Q-S7-7 (a)). Selectors: mint(address,uint256)
  # 40c10f19, transfer(address,uint256) a9059cbb, balanceOf(address) 70a08231.
  # Before bindToken, created reverts (fromToken), so the mint reverts. The
  # lock of alice (pLockD 3600) makes canTransfer no. After setLockD 0u, bob
  # (no registration) is not verified, 11 is above the balance of carol, and
  # carol to dave moves 4. Then the token balances equal the restrictkit
  # mirror (the created and transferred hooks).
  build/asmtool token >"$tmp/token"
  : >"$tmp/traw"
  tcall revert "$dave" 40c10f19 ${alice#0x} a
  call ok "$dave" bindToken $testToken
  tcall ok "$dave" 40c10f19 ${alice#0x} a
  call "out $(pad a)" "$dave" balanceOf $alice
  tcall revert "$alice" a9059cbb ${dave#0x} 4
  call ok "$dao" setLockD 0u
  tcall ok "$dave" 40c10f19 ${carol#0x} a
  tcall revert "$carol" a9059cbb ${bob#0x} 1
  tcall revert "$carol" a9059cbb ${dave#0x} b
  tcall "out $(pad 1)" "$carol" a9059cbb ${dave#0x} 4
  tcall "out $(pad 6)" "$dave" 70a08231 ${carol#0x}
  call "out $(pad 6)" "$dave" balanceOf $carol
  tcall "out $(pad 4)" "$dave" 70a08231 ${dave#0x}
  call "out $(pad 4)" "$dave" balanceOf $dave
  call "out $(pad 3)" "$dave" holderCount
fi

# The ABI row (S7 s4, Q-S7-8 (a)): `langc --kit abi --text` gives the 9 EIP
# selectors of docs/PLAN.md section 16 (`cast sig`).
build/langc --kit abi "$prog" --text >"$tmp/abi" 2>&1
abis=0
for row in 0x3ff5aa02:bindToken 0x40db3b50:unbindToken 0x993e8b95:isTokenBound \
  0x6a3edf28:getTokenBound 0xe46638e6:canTransfer 0x8baf29b4:transferred \
  0x5f8dead3:created 0x8d2ea772:destroyed 0xb9209e33:isVerified; do
  abis=$((abis + 1))
  if ! awk -v s="${row%%:*}" -v n="${row#*:}(" '$1 == s && index($2, n) == 1 { f = 1 } END { exit !f }' "$tmp/abi"; then
    echo "FAIL restrict abi: ${row#*:} is not ${row%%:*}"
    fail=$((fail + 1))
  fi
done

# The EIP-170 rows (S7 s4, O15): the runtime at most 24576 bytes and the
# initcode at most 49152 bytes (EIP-3860) of restrictkit and natkit. The bytes
# are the hex chars / 2 of `langc --kit build` (--runtime gives the runtime).
sizes=
for kit in restrictkit natkit; do
  rbytes=$(($(build/langc --kit build "examples/$kit.lang" --runtime | wc -c) / 2))
  ibytes=$(($(build/langc --kit build "examples/$kit.lang" | wc -c) / 2))
  sizes="$sizes, $kit runtime $rbytes initcode $ibytes"
  [ "$rbytes" -le 24576 ] || { echo "FAIL restrict size: $kit runtime $rbytes > 24576 (O15)"; fail=$((fail + 1)); }
  [ "$ibytes" -le 49152 ] || { echo "FAIL restrict size: $kit initcode $ibytes > 49152 (O15)"; fail=$((fail + 1)); }
done

rm -rf "$tmp"
echo "restrict size rows: ${sizes#, } bytes (limit runtime 24576, initcode 49152)"
echo "restrict abi: $abis EIP selectors checked"
echo "restrict: $steps steps checked"
echo "restrict gate: $fail failures"
[ "$fail" -eq 0 ]
