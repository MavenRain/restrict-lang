# Chain helpers for test/evm.sh (slice K4c) and test/mock.sh (slice K4d),
# modeled on the anchor kit test/evmchain.sh. Source this file from the kit
# root. The helpers need evm (go-ethereum), bc, od and build/slottool. The
# caller sets tmp, a work directory.

# The receiver of each call, and the config of each prestate: each fork at
# block 0 and shanghaiTime 0 (PUSH0).
receiver=0000000000000000000000007265636569766572
config='{"chainId":1,"homesteadBlock":0,"eip150Block":0,"eip155Block":0,"eip158Block":0,"byzantiumBlock":0,"constantinopleBlock":0,"petersburgBlock":0,"istanbulBlock":0,"berlinBlock":0,"londonBlock":0,"mergeNetsplitBlock":0,"shanghaiTime":0,"terminalTotalDifficulty":0,"terminalTotalDifficultyPassed":true}'
# The t8n route (S10, O36): a chain that sets numbered=1 runs each step with
# BLOCK > 0 on `evm t8n`, from the address key of the secret key below.
key=a94f5374fce5edbc8e2a8697c15331677e6ebf0b
secret=45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8

# keccak HEX: keccak256 of the bytes HEX (CALLDATACOPY, SHA3, RETURN of 32 bytes).
keccak() { evm run --code 365f5f37365f205f5260205ff3 --input "$1" 2>&1 | cut -c3-; }
# sel TEXT: the selector of the signature TEXT.
sel() { keccak "$(printf '%s' "$1" | od -v -An -tx1 | tr -d ' \n')" | cut -c1-8; }
# pad H: H as 64 hex digits.
pad() { printf '%64s' "$1" | tr ' ' 0; }

# hexnorm H: the hex number H in lowercase with no leading zeros ("0" for zero).
hexnorm() {
  printf 'obase=16; ibase=16; %s\n' "$(printf '%s' "$1" | tr a-f A-F)" | bc | tr A-F a-f
}

# word TOKEN: the word of a value that `langc run` reads or prints, as hexnorm.
word() {
  case $1 in
    0x*u) _h=${1#0x}; hexnorm "${_h%u}" ;;
    0x*) hexnorm "${1#0x}" ;;
    flagYes) echo 1 ;;
    flagNo) echo 0 ;;
    *u) printf 'obase=16; %s\n' "${1%u}" | bc | tr A-F a-f ;;
    *) printf 'obase=16; %s\n' "$1" | bc | tr A-F a-f ;;
  esac
}

# types PROG NAME: the ABI types of the arguments of the entry or view NAME,
# from the `langc abi` line of NAME (C-K4-16): Nat uint64, Flag bool, U256
# uint256 and Addr address. Env and State are not arguments of the call.
types() {
  build/langc --kit abi "$1" --text >"$tmp/types" || return 1
  awk -v n="$2" '$3 != "event" && index($2, n "(") == 1 {
    s = substr($2, length(n) + 2)
    print substr(s, 1, length(s) - 1)
  }' "$tmp/types"
}

# input PROG NAME ARGS...: the call data of the entry NAME of PROG with the
# arguments ARGS. The selector comes from the SHA3 op of evm, not from langc.
input() {
  _sig="$2($(types "$1" "$2"))"
  shift 2
  _words=''
  for _a in "$@"; do
    _words=$_words$(pad "$(word "$_a")")
  done
  printf '%s%s\n' "$(sel "$_sig")" "$_words"
}

# put SLOT VALUE: one expected storage row. A zero word is not stored.
put() {
  [ "$2" = 0 ] || echo "$1 $2" >>"$tmp/want.rows"
}

# list SLOT ARG: the length n at SLOT, element j at keccak256(SLOT) + (n-1-j) (C-c9-1).
list() {
  _base=$(build/slottool "$1")
  _len=$(printf '%s' "$2" | tr -d '()' | awk '{ for (i = 1; i <= NF; i++) if ($i != "cons" && $i != "nil") c++ } END { print c + 0 }')
  _j=0
  for _t in $(printf '%s' "$2" | tr -d '()'); do
    case $_t in
      cons|nil) ;;
      *)
        _at=$(printf 'obase=16; ibase=16; %s + %X\n' "$(printf '%s' "$_base" | tr a-f A-F)" "$((_len - 1 - _j))" | bc | tr A-F a-f)
        put "$(pad "$_at")" "$(word "$_t")"
        _j=$((_j + 1)) ;;
    esac
  done
  put "$1" "$(word "$_j")"
}

# map SLOT ARG: the value at key k at keccak256(k . SLOT).
map() {
  _slot=$1
  set -- $(printf '%s' "$2" | tr -d '()[],')
  shift
  while [ "$#" -ge 2 ]; do
    put "$(build/slottool "$(pad "$(word "$1")")$_slot")" "$(word "$2")"
    shift 2
  done
}

# want STATE: tmp/want gets the sorted storage rows `SLOT VALUE` of the state
# text STATE (`makeState ARGS...`). Field i of the state is at slot i.
want() {
  : >"$tmp/want.rows"
  printf '%s\n' "$1" | awk '{
    s = $0; sub(/^makeState /, "", s); d = 0; a = ""
    for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (c == "(" || c == "[") d++
      if (c == ")" || c == "]") d--
      if (c == " " && d == 0) { print a; a = "" } else a = a c
    }
    if (a != "") print a
  }' >"$tmp/args"
  _n=0
  while IFS= read -r _arg; do
    _s=$(pad "$(printf '%x' "$_n")")
    case $_arg in
      "(cons "*|nil) list "$_s" "$_arg" ;;
      "(mapOf "*) map "$_s" "$_arg" ;;
      *) put "$_s" "$(word "$_arg")" ;;
    esac
    _n=$((_n + 1))
  done <"$tmp/args"
  sort "$tmp/want.rows" >"$tmp/want"
}

# slots DUMP: tmp/raw gets the storage rows `SLOT VALUE` of the evm dump DUMP
# as evm writes them, tmp/got the same rows with VALUE as hexnorm, sorted.
slots() {
  awk -F'"' 'NF >= 5 && length($2) == 66 && substr($2, 1, 2) == "0x" { print substr($2, 3), $4 }' "$1" >"$tmp/raw"
  awk '{ v = tolower($2); sub(/^0+/, "", v); print $1, (v == "" ? "0" : v) }' "$tmp/raw" | sort >"$tmp/got"
}

# genesis TIME ALLOC: tmp/pre.json gets a prestate at TIMESTAMP TIME with the
# alloc entries ALLOC. The prestate has no block number: `evm run` (1.14)
# refuses a genesis with number > 0 (S8, O17). A step at NUMBER > 0 is a t8n
# step (S10, O36).
genesis() {
  printf '{"config":%s,"timestamp":"0x%x","gasLimit":"0x1c9c380","difficulty":"0x0","alloc":{%s}}\n' \
    "$config" "$1" "$2" >"$tmp/pre.json"
}

# deploy PROG: run the creation code of PROG. tmp/code gets the code of the
# new account, tmp/raw and tmp/got its storage.
deploy() {
  genesis 0 ''
  _hex=$(build/langc --kit build "$1") || return 1
  evm run --prestate "$tmp/pre.json" --create --code "$_hex" --dump >"$tmp/dump" 2>&1 || return 1
  awk '$1 == "\"code\":" { v = $2; gsub(/[",]/, "", v); print tolower(substr(v, 3)); exit }' "$tmp/dump" >"$tmp/code"
  [ -s "$tmp/code" ] || return 1
  slots "$tmp/dump"
}

# step NOW BLOCK CALLER INPUT: call the receiver (the code in tmp/code, the
# storage in tmp/raw) from CALLER with INPUT at TIMESTAMP NOW. BLOCK (the
# `langc run` column, O17) is not in the prestate: NUMBER is 0. With
# numbered=1 and BLOCK > 0, the step is a t8n step at NUMBER BLOCK (S10,
# O36) and CALLER must be 0x$key. result gets ok, revert, trap (the Trap()
# selector), error, `revert HEX` or `out HEX`. tmp/raw and tmp/got get the
# storage after the call, stepped gets run or t8n. A set alloc
# (`,"0xADDR":{...}`) adds accounts to the prestate (test/diff.sh: the mock
# token); then tmp/raw holds the storage of all accounts.
step() {
  _st=$(awk '{ printf "%s\"0x%s\":\"0x%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$tmp/raw")
  _acc="\"0x$receiver\":{\"balance\":\"0x0\",\"code\":\"0x$(cat "$tmp/code")\",\"storage\":{$_st}}${alloc:-}"
  if [ "${numbered:-0}" = 1 ] && [ "${2%u}" != 0 ]; then
    stepped=t8n
    t8n "$1" "${2%u}" "$3" "$4" "$_acc" || return 1
    slots "$tmp/dump"
    return 0
  fi
  stepped=run
  genesis "$1" "$_acc"
  evm run --prestate "$tmp/pre.json" --receiver "0x$receiver" --sender "$3" --input "$4" \
    --dump >"$tmp/dump" 2>&1 || return 1
  result=$(awk '
    /^0x[0-9a-f]*$/ { o = $0 }
    / error: |^error: / { e = 1; if ($0 !~ /execution reverted/) x = 1 }
    END {
      if (x) print "error"
      else if (e && o == "0xae96083a") print "trap"
      else if (e && (o == "" || o == "0x")) print "revert"
      else if (e) print "revert " substr(o, 3)
      else if (o == "" || o == "0x") print "ok"
      else print "out " substr(o, 3)
    }' "$tmp/dump")
  slots "$tmp/dump"
}

# t8n NOW BLOCK CALLER INPUT ALLOC: one `evm t8n` call (Shanghai; S10, O36)
# from the key address to the receiver with INPUT at TIMESTAMP NOW and NUMBER
# BLOCK, on the alloc entries ALLOC and the key account (nonce 0). It fails
# if CALLER is not 0x$key. tmp/dump gets the output alloc in the form of
# `evm run --dump` (each storage value without 0x and leading zero bytes). result
# comes from the trace summary (the last trace line: output, gasUsed and, on
# a revert or a trap, error), gas gets its gasUsed: the execution gas, the
# base of `evm run --statdump` (result.json gasUsed adds the intrinsic gas).
# tmp/t8n/result.json holds the receipt (the logs of the call).
t8n() {
  [ "$3" = "0x$key" ] || { echo "t8n: the caller $3 is not the key address 0x$key" >"$tmp/dump"; return 1; }
  rm -rf "$tmp/t8n"
  mkdir -p "$tmp/t8n"
  printf '{%s,"0x%s":{"balance":"0x3635c9adc5dea00000","nonce":"0x0","code":"0x","storage":{}}}\n' \
    "$5" "$key" >"$tmp/t8n/alloc.json"
  printf '{"currentCoinbase":"0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba","currentDifficulty":"0x0","currentRandom":"0x%s","currentGasLimit":"0x1c9c380","currentNumber":"0x%x","currentTimestamp":"0x%x","currentBaseFee":"0x7","withdrawals":[]}\n' \
    "$(pad 0)" "$2" "$1" >"$tmp/t8n/env.json"
  printf '[{"type":"0x0","gas":"0x1c9c380","gasPrice":"0x10","nonce":"0x0","to":"0x%s","value":"0x0","input":"0x%s","v":"0x0","r":"0x0","s":"0x0","secretKey":"0x%s","protected":false}]\n' \
    "$receiver" "$4" "$secret" >"$tmp/t8n/txs.json"
  evm t8n --input.alloc "$tmp/t8n/alloc.json" --input.env "$tmp/t8n/env.json" --input.txs "$tmp/t8n/txs.json" \
    --state.fork Shanghai --output.basedir "$tmp/t8n" --output.result result.json --output.alloc alloc.out.json \
    --trace >"$tmp/t8n/log" 2>&1 || { cp "$tmp/t8n/log" "$tmp/dump"; return 1; }
  _trace=$(ls "$tmp/t8n"/trace-0-*.jsonl 2>/dev/null)
  [ -n "$_trace" ] || { echo "t8n: the call was rejected (no trace)" >"$tmp/dump"; return 1; }
  awk -F'"' -v OFS='"' 'NF >= 5 && length($2) == 66 && substr($2, 1, 2) == "0x" {
      v = tolower(substr($4, 3)); sub(/^(00)+/, "", v); $4 = (v == "" ? "00" : v) }
    { print }' "$tmp/t8n/alloc.out.json" >"$tmp/dump"
  tail -n 1 "$_trace" | awk -F'"' '{ for (i = 2; i + 2 <= NF; i += 4) v[$i] = $(i + 2) }
    END { print v["gasUsed"]; print v["output"]; print v["error"] }' >"$tmp/t8n/sum"
  gas=$(printf '%d' "$(awk 'NR == 1' "$tmp/t8n/sum")")
  result=$(awk '
    NR == 2 { o = $0 }
    NR == 3 { e = $0 }
    END {
      if (e != "" && e != "execution reverted") print "error"
      else if (e != "" && o == "ae96083a") print "trap"
      else if (e != "" && o == "") print "revert"
      else if (e != "") print "revert " o
      else if (o == "") print "ok"
      else print "out " o
    }' "$tmp/t8n/sum")
}

# logs CALLER INPUT: the logs of the step on tmp/pre.json (the LOGS block of
# `evm run --debug`), one line for each LOG: the topics and the data. After a
# t8n step, the logs of the receipt in tmp/t8n/result.json.
logs() {
  if [ "${stepped:-run}" = t8n ]; then
    awk -F'"' '
      $2 == "topics" { t = ""; q = 1; next }
      q && substr($2, 1, 2) == "0x" { t = t (t == "" ? "" : ",") substr($2, 3); next }
      q { q = 0 }
      $2 == "data" { d = substr($4, 3); print t " " (d == "" ? "-" : d); t = "" }' "$tmp/t8n/result.json" >"$tmp/gotlogs"
    return 0
  fi
  evm run --debug --prestate "$tmp/pre.json" --receiver "0x$receiver" --sender "$1" --input "$2" \
    >"$tmp/debug" 2>&1 </dev/null || return 1
  awk '
    /^#### LOGS ####/ { p = 1; next }
    /^####/ { p = 0 }
    !p { next }
    /^LOG[0-4]:/ { if (n) print t " " (d == "" ? "-" : d); n = 1; t = ""; d = ""; next }
    length($2) == 64 { t = t (t == "" ? "" : ",") $2; next }
    { for (i = 2; i <= NF && $i ~ /^[0-9a-f][0-9a-f]$/; i++) d = d $i }
    END { if (n) print t " " (d == "" ? "-" : d) }' "$tmp/debug" >"$tmp/gotlogs"
}
