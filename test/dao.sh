#!/bin/sh
# The DAO chain gate (S10 b4, Q-S10-4, Q-S10-10). Deploy examples/daokit.lang,
# check the size limits (O15: the runtime at most 24576 bytes, EIP-170; the
# initcode at most 49152 bytes, EIP-3860), then run the cast and enact calls
# of the kit eval rows on the chain. The casts are at BLOCK 0 (`evm run`, from
# the voter address); the late castSeal and enact are at BLOCK 11 (more than
# castEnd 10), on `evm t8n` from the key address (numbered=1, O36). The words
# are the output of `build/ballottool dao` and `build/ballottool words`: the
# 3 ballots, the slot 0 opening ty (m 2) and the slot 1 host sum tn. The tally
# views must equal the host sums T0 = ty and T1 = tn. The line `dao gas rows`
# gives the execution gas of deploy, castSig, castSlot, castSeal (the first
# and a later one) and enact (S10 b6); the gate does not check it. It needs evm
# (go-ethereum), bc, od, build/slottool and build/ballottool. Run it from the
# kit root.
#
# The second prestate (S7 s5) comes next. examples/restrictdao.lang is at the
# address 0x..da and examples/restrictkit.lang is at the kitAddr word
# 0x..7265636569766572. The 3 ballots of `build/ballottool rdao` (the context
# word is hash(0x..da, 1)) go to restrictdao, and its enact calls setCapN 4u on
# restrictkit. The kit word pCapN (storage slot 0x0b) must change from 2 to 4.
# A setCapN call from the voter to restrictkit reverts (fromDao is false).
set -u
fail=0
steps=0
tmp=${TMPDIR:-/tmp}/langc-dao.$$
mkdir -p "$tmp"
. test/evmchain.sh

prog=examples/daokit.lang
voter=0x00000000000000000000000000000000000000aa
numbered=1
{ build/ballottool dao && build/ballottool words; } >"$tmp/words" || { echo "FAIL dao: ballottool"; exit 1; }

# ws PREFIX NAMES...: the words PREFIX.NAME of tmp/words as `langc run`
# tokens, in the order of NAMES (the first row of each name).
ws() {
  _p=$1
  shift
  printf '%s\n' "$@" | awk -v p="$_p" 'NR == FNR { if (!($1 in v)) v[$1] = $2; next } { print v[p $1] "u" }' "$tmp/words" -
}

# hw NAME: the word NAME of tmp/words as hexnorm (a view result).
hw() { hexnorm "$(ws "" "$1" | cut -c3- | tr -d u)"; }

# sig V, slot V J, seal V: the arguments of the castSig, castSlot J and
# castSeal calls of voter V (0, 1 or 2).
sig() { ws "b$1" ix iy j0c1x j0c1y j0c2x j0c2y j1c1x j1c1y j1c2x j1c2y c1 s1 s2 s3; }
slot() {
  ws "b$1" ix iy
  echo "$2u"
  ws "b$1j$2" a0x a0y b0x b0y a1x a1y b1x b1y e0 e1 z0 z1
}
seal() { ws "b$1" ix iy sumax sumay sumbx sumby sumz; }

# opening M: the arguments of enact, the slot 0 shares of ty with m M.
opening() {
  ws ty d1x d1y a1x a1y b1x b1y z1 d2x d2y a2x a2y b2x b2y z2
  echo "$1u"
}

# call WANT NAME BLOCK ARGS...: one step of the entry or view NAME with ARGS at
# NOW = BLOCK. At BLOCK 0 the step is `evm run` from the voter, at BLOCK > 0 a
# t8n step from the key address. The result must equal WANT: `out HEX` (HEX as
# hexnorm), ok or revert. An entry changes the storage of the next step.
call() {
  _want=$1 _name=$2 _block=$3
  shift 3
  steps=$((steps + 1))
  _from=$voter
  [ "$_block" = 0 ] || _from=0x$key
  _input=$(input "$prog" "$_name" "$@")
  if ! step "$_block" "${_block}u" "$_from" "$_input"; then
    echo "FAIL dao $_name (step $steps): evm: $(head -n 1 "$tmp/dump")"
    fail=$((fail + 1))
    return
  fi
  case $result in
    "out "*) _hex=${result#out }
      [ ${#_hex} -eq 64 ] && result="out $(hexnorm "$_hex")" ;;
  esac
  if [ "$result" != "$_want" ]; then
    echo "FAIL dao $_name (step $steps): want $_want, got $result"
    fail=$((fail + 1))
  fi
}

# gasrow NAME: add the execution gas of the last call to the gas line as NAME:
# the trace summary gasUsed (gas) after a t8n step, else `evm run --statdump`
# of the same call on the same prestate (tmp/pre.json).
gasrows=
gasrow() {
  [ "$stepped" = t8n ] || gas=$(evm run --prestate "$tmp/pre.json" --receiver "0x$receiver" --sender "$_from" \
    --input "$_input" --statdump 2>&1 >/dev/null | awk '$1 == "EVM" { print $4 }')
  gasrows="$gasrows, $1 $gas"
}

# cast V [CALL]: the 4 calls of voter V at BLOCK 0 with the helper CALL (call
# when it is not set, rdao for the second prestate).
cast() {
  _c=${2:-call}
  $_c ok castSig 0 $(sig "$1")
  $_c ok castSlot 0 $(slot "$1" 0)
  $_c ok castSlot 0 $(slot "$1" 1)
  $_c ok castSeal 0 $(seal "$1")
}

if ! deploy "$prog"; then
  echo "FAIL dao deploy: $(head -n 1 "$tmp/dump")"
  rm -rf "$tmp"
  echo "dao chain: 0 steps, 1 failures"
  exit 1
fi
init=$(build/langc --kit build "$prog")
# `evm run --create --statdump` prints the gas left (go-ethereum 1.14.12), not
# the gas used: the deploy gas is the genesis gas limit (0x1c9c380) minus it.
dgas=$((30000000 - $(evm run --prestate "$tmp/pre.json" --create --code "$init" --statdump 2>&1 >/dev/null |
  awk '$1 == "EVM" { print $4 }')))
ibytes=$((${#init} / 2))
rbytes=$(awk '{ print length($0) / 2; exit }' "$tmp/code")
echo "dao size rows: runtime $rbytes bytes (limit 24576), initcode $ibytes bytes (limit 49152)"
[ "$rbytes" -le 24576 ] || { echo "FAIL dao size: runtime $rbytes > 24576 (O15)"; fail=$((fail + 1)); }
[ "$ibytes" -le 49152 ] || { echo "FAIL dao size: initcode $ibytes > 49152 (O15)"; fail=$((fail + 1)); }

# Voter 0, with the stage view after each part: a seal before castSlot
# reverts, and a second cast of voter 0 after the seal reverts (used).
call ok castSig 0 $(sig 0)
gasrow castSig
call "out 1" stageOf 0 $(ws b0 ix iy)
call revert castSeal 0 $(seal 0)
call ok castSlot 0 $(slot 0 0)
gasrow castSlot
call "out 3" stageOf 0 $(ws b0 ix iy)
call ok castSlot 0 $(slot 0 1)
call "out 7" stageOf 0 $(ws b0 ix iy)
call ok castSeal 0 $(seal 0)
gasrow "castSeal first"
call revert castSig 0 $(sig 0)
cast 1
gasrow "castSeal later"

# Voter 2: a late castSeal (BLOCK 11 > castEnd) reverts, the seal at BLOCK 0
# does not.
call ok castSig 0 $(sig 2)
call ok castSlot 0 $(slot 2 0)
call ok castSlot 0 $(slot 2 1)
call revert castSeal 11 $(seal 2)
call ok castSeal 0 $(seal 2)
call "out 3" castCount 0

# The tally views: T0 = the host sum ty, T1 = the host sum tn (tallyWord 0 ..
# 7 = t0ax t0ay t0bx t0by t1ax t1ay t1bx t1by).
call "out $(hw tyc1x)" tallyWord 0 0u
call "out $(hw tyc1y)" tallyWord 0 1u
call "out $(hw tyc2x)" tallyWord 0 2u
call "out $(hw tyc2y)" tallyWord 0 3u
call "out $(hw tnc1x)" tallyWord 0 4u
call "out $(hw tnc1y)" tallyWord 0 5u
call "out $(hw tnc2x)" tallyWord 0 6u
call "out $(hw tnc2y)" tallyWord 0 7u

# enact: early (BLOCK 0) reverts, m 3 reverts, m 2 (yes 2, no 1) sets the
# window 6 -> 4, a second enact reverts.
call "out 6" windowNow 0
call revert enact 0 $(opening 2)
call revert enact 11 $(opening 3)
call ok enact 11 $(opening 2)
gasrow enact
call "out 4" windowNow 0
call revert enact 11 $(opening 2)

# The second prestate (S7 s5): restrictdao at 0x..da, restrictkit at the
# kitAddr word. The dump of a step holds the storage of the two accounts, and
# slots merges it: keep puts the storage of each account in its own file.
daoacc=00000000000000000000000000000000000000da
kitacc=0000000000000000000000007265636569766572

# rdeploy: deploy restrictkit, then restrictdao. tmp/WHO.code and tmp/WHO.raw
# (WHO is kit or dao) get the code and the storage of each.
rdeploy() {
  deploy examples/restrictkit.lang && cp "$tmp/code" "$tmp/kit.code" && cp "$tmp/raw" "$tmp/kit.raw" &&
    deploy examples/restrictdao.lang && cp "$tmp/code" "$tmp/dao.code" && cp "$tmp/raw" "$tmp/dao.raw"
}

# on WHO: the next step goes to WHO (dao or kit) with the code and the storage
# of WHO. alloc gets the other account with its code and storage.
on() {
  case $1 in
    dao) receiver=$daoacc prog=examples/restrictdao.lang _o=kit _oacc=$kitacc ;;
    kit) receiver=$kitacc prog=examples/restrictkit.lang _o=dao _oacc=$daoacc ;;
  esac
  cp "$tmp/$1.code" "$tmp/code"
  cp "$tmp/$1.raw" "$tmp/raw"
  alloc=",\"0x$_oacc\":{\"balance\":\"0x0\",\"code\":\"0x$(cat "$tmp/$_o.code")\",\"storage\":{$(
    awk '{ printf "%s\"0x%s\":\"0x%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$tmp/$_o.raw")}}"
}

# keep: tmp/dao.raw and tmp/kit.raw get the storage rows of each account of
# the last dump. An account line of the dump is `"0xADDR": {`; `evm run` can
# write ADDR with capital letters.
keep() {
  awk -F'"' -v d="$daoacc" -v k="$kitacc" -v t="$tmp" '
    BEGIN { f[d] = t "/dao.raw"; f[k] = t "/kit.raw"; printf "" >(f[d]); printf "" >(f[k]) }
    length($2) == 42 && $3 ~ /\{/ { a = tolower(substr($2, 3)); next }
    NF >= 5 && length($2) == 66 && substr($2, 1, 2) == "0x" && (a in f) { print substr($2, 3), $4 >(f[a]) }' "$tmp/dump"
}

# rdao and rkit WANT NAME BLOCK ARGS...: call to restrictdao or to restrictkit
# on the second prestate.
rdao() { on dao; call "$@"; keep; }
rkit() { on kit; call "$@"; keep; }

# capn WANT: the kit word pCapN (slot 0x0b, field 11 of the kit State) must
# equal WANT (as hexnorm).
capn() {
  steps=$((steps + 1))
  _v=$(awk -v s="$(pad b)" '$1 == s { print $2 }' "$tmp/kit.raw")
  [ "$(hexnorm "${_v:-0}")" = "$1" ] || { echo "FAIL dao pCapN (step $steps): want $1, got ${_v:-0}"; fail=$((fail + 1)); }
}

{ build/ballottool rdao && build/ballottool words; } >"$tmp/words" || { echo "FAIL dao: ballottool rdao"; exit 1; }
if ! rdeploy; then
  echo "FAIL dao rdao deploy: $(head -n 1 "$tmp/dump")"
  rm -rf "$tmp"
  echo "dao chain: $steps steps, $((fail + 1)) failures"
  exit 1
fi
rinit=$(build/langc --kit build examples/restrictdao.lang)
ribytes=$((${#rinit} / 2))
rrbytes=$(awk '{ print length($0) / 2; exit }' "$tmp/dao.code")
echo "rdao size rows: runtime $rrbytes bytes (limit 24576), initcode $ribytes bytes (limit 49152)"
[ "$rrbytes" -le 24576 ] || { echo "FAIL rdao size: runtime $rrbytes > 24576 (O15)"; fail=$((fail + 1)); }
[ "$ribytes" -le 49152 ] || { echo "FAIL rdao size: initcode $ribytes > 49152 (O15)"; fail=$((fail + 1)); }

# The 3 casts, then the tally views (T0 = ty, T1 = tn).
cast 0 rdao
cast 1 rdao
cast 2 rdao
rdao "out 3" castCount 0
_k=0
for _n in tyc1x tyc1y tyc2x tyc2y tnc1x tnc1y tnc2x tnc2y; do
  rdao "out $(hw "$_n")" tallyWord 0 "${_k}u"
  _k=$((_k + 1))
done

# enact: m 2 (yes 2, no 1) sets the window 6 -> 4 and calls setCapN 4u on
# restrictkit (pCapN 2 -> 4). Before it, a setCapN from the voter reverts.
# A second enact reverts.
rdao "out 6" windowNow 0
capn 2
rkit revert setCapN 0 4u
capn 2
rdao ok enact 11 $(opening 2)
gasrow "rdao enact"
rdao "out 4" windowNow 0
capn 4
rdao revert enact 11 $(opening 2)
capn 4

rm -rf "$tmp"
echo "dao gas rows: deploy $dgas$gasrows"
echo "dao chain: $steps steps, $fail failures"
[ "$fail" -eq 0 ]
