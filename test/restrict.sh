#!/bin/sh
# The restrict chain gate (S7 s3, Q-S7-14 (e1)). Deploy examples/restrictkit.lang,
# then run the issue and register calls of the kit rows on the chain, at
# TIMESTAMP 1. issue takes five words (c i kx ky hc): hc is the H_p counter of
# the key at the contract word wC (hpIdx: zkKey 13 0u, zkKey 2 5u, zkKey 18 7u),
# and the MODEXP loop of register computes H_p of each ring point. The words
# are `langc --kit eval examples/restrictkit.lang` of k0, k1, k2, kR, sigD and
# img0. It needs evm (go-ethereum), bc, od and build/slottool. Run it from the
# kit root.
set -u
fail=0
steps=0
tmp=${TMPDIR:-/tmp}/langc-restrict.$$
mkdir -p "$tmp"
. test/evmchain.sh

prog=examples/restrictkit.lang
issuer=0x00000000000000000000000000000000000000e1
dave=0x00000000000000000000000000000000000000dd

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
fi

rm -rf "$tmp"
echo "restrict: $steps steps checked"
echo "restrict gate: $fail failures"
[ "$fail" -eq 0 ]
