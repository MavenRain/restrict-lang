/* The self-test of the assembler, keccak and the ABI selectors.
   Usage: asmtool            runs the checks; exit 0 when all pass
          asmtool runtime    the runtime hex of a program that returns 42
          asmtool creation   the creation hex of that program
          asmtool abi        the `langc abi` line of addPrice(Nat, Flag) */
#include <stdio.h>
#include <string.h>

#include "asm.h"
#include "keccak.h"
#include "target.h"

enum { CHECKS = 8 };

static void to_hex(const unsigned char *bytes, size_t size, char *text) {
  for (size_t i = 0; i < size; i++) snprintf(text + 2 * i, 3, "%02x", bytes[i]);
  text[2 * size] = '\0';
}

/* Returns 1 when the hex of keccak256(INPUT) starts with WANT, else 0 after
   a FAIL line. */
static int check_keccak(const char *input, const char *want) {
  unsigned char digest[32];
  char text[65];
  keccak256((const unsigned char *)input, strlen(input), digest);
  to_hex(digest, 32, text);
  if (strncmp(text, want, strlen(want)) == 0) return 1;
  printf("FAIL keccak256(\"%s\"): want %s, got %s\n", input, want, text);
  return 0;
}

/* Jumps forward to `start`, which jumps back to `back`, which returns the
   word 42. */
static int answer(Asm *a, FILE *err) {
  asm_init(a);
  Label start = asm_label(a);
  Label back = asm_label(a);
  asm_jump(a, start);
  asm_jumpdest(a, back);
  asm_push(a, 42);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_MSTORE);
  asm_push(a, 32);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_RETURN);
  asm_jumpdest(a, start);
  asm_jump(a, back);
  return asm_finish(a, err);
}

/* MLOAD of the word at memory offset AT. */
static void mload(Asm *a, uint64_t at) {
  asm_push(a, at);
  asm_op(a, EVM_OP_MLOAD);
}

/* Memory offset TO gets the call data word at offset AT. */
static void arg(Asm *a, uint64_t at, uint64_t to) {
  asm_push(a, at);
  asm_op(a, EVM_OP_CALLDATALOAD);
  asm_push(a, to);
  asm_op(a, EVM_OP_MSTORE);
}

/* Returns the word VALUE. */
static void return_word(Asm *a, uint64_t value) {
  asm_push(a, value);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_MSTORE);
  asm_push(a, 32);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_RETURN);
}

/* The mock ERC-20 token of slice K4d (C-K4d-3) for the CALL tests: the
   runtime of transfer(address,uint256) (from is the caller) and
   transferFrom(address,address,uint256). Slot 0 is the mode: 0 moves and
   returns the word 1, 1 returns the word 0 with no move, 2 moves and returns
   empty data, any other mode reverts. The balance of an address is at the
   slot equal to the address word. A move has no balance check and no
   allowance check (wrapping SUB, then ADD: a move to the sender keeps the
   balance) and makes one LOG3 Transfer(from, to) with the amount as data.
   Memory: 0x00 the amount, 0x20 from, 0x40 to. Another selector reverts. */
static int mock(Asm *a, FILE *err) {
  const char *event = "Transfer(address,address,uint256)";
  unsigned char topic[32];
  keccak256((const unsigned char *)event, strlen(event), topic);
  asm_init(a);
  Label transfer = asm_label(a);
  Label from = asm_label(a);
  Label move = asm_label(a);
  Label stop = asm_label(a);
  Label no = asm_label(a);
  Label revert = asm_label(a);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_CALLDATALOAD);
  asm_push(a, 0xe0);
  asm_op(a, EVM_OP_SHR);
  asm_op(a, EVM_OP_DUP1);
  asm_push(a, 0xa9059cbb);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, transfer);
  asm_push(a, 0x23b872dd);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, from);
  asm_jump(a, revert);
  asm_jumpdest(a, transfer);
  asm_op(a, EVM_OP_POP);
  asm_op(a, EVM_OP_CALLER);
  asm_push(a, 0x20);
  asm_op(a, EVM_OP_MSTORE);
  arg(a, 0x04, 0x40);
  arg(a, 0x24, 0x00);
  asm_jump(a, move);
  asm_jumpdest(a, from);
  arg(a, 0x04, 0x20);
  arg(a, 0x24, 0x40);
  arg(a, 0x44, 0x00);
  asm_jumpdest(a, move);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_DUP1);
  asm_push(a, 2);
  asm_op(a, EVM_OP_LT); /* 2 < mode */
  asm_jump_if(a, revert);
  asm_op(a, EVM_OP_DUP1);
  asm_push(a, 1);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, no);
  mload(a, 0x00);
  mload(a, 0x20);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_SUB);
  mload(a, 0x20);
  asm_op(a, EVM_OP_SSTORE);
  mload(a, 0x00);
  mload(a, 0x40);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_ADD);
  mload(a, 0x40);
  asm_op(a, EVM_OP_SSTORE);
  mload(a, 0x40); /* topic 2: to */
  mload(a, 0x20); /* topic 1: from */
  asm_push_word(a, topic);
  asm_push(a, 32);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_LOG3);
  asm_push(a, 2);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, stop);
  return_word(a, 1);
  asm_jumpdest(a, stop);
  asm_op(a, EVM_OP_STOP);
  asm_jumpdest(a, no);
  return_word(a, 0);
  asm_jumpdest(a, revert);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_REVERT);
  return asm_finish(a, err);
}

/* The compliance contract of the test token: the receiver address of
   test/evmchain.sh. */
static const uint64_t compliance = 0x7265636569766572u;

/* Calls the compliance contract with the selector SEL and the N memory words
   at AT as the arguments (the call data at 0x80, the returned word at 0x60).
   A failed call jumps to REVERT; with VIEW, a returned word 0 (or no returned
   word) also jumps to REVERT. */
static void comply(Asm *a, uint64_t sel, const uint64_t *at, size_t n, int view, Label revert) {
  asm_op(a, EVM_OP_PUSH0);
  asm_push(a, 0x60);
  asm_op(a, EVM_OP_MSTORE);
  asm_push(a, sel);
  asm_push(a, 0xe0);
  asm_op(a, EVM_OP_SHL);
  asm_push(a, 0x80);
  asm_op(a, EVM_OP_MSTORE);
  for (size_t i = 0; i < n; i++) {
    mload(a, at[i]);
    asm_push(a, 0x84 + 0x20 * i);
    asm_op(a, EVM_OP_MSTORE);
  }
  asm_push(a, 32);
  asm_push(a, 0x60);
  asm_push(a, 4 + 0x20 * n);
  asm_push(a, 0x80);
  asm_op(a, EVM_OP_PUSH0);
  asm_push(a, compliance);
  asm_op(a, EVM_OP_GAS);
  asm_op(a, EVM_OP_CALL);
  asm_op(a, EVM_OP_ISZERO);
  asm_jump_if(a, revert);
  if (view) {
    mload(a, 0x60);
    asm_op(a, EVM_OP_ISZERO);
    asm_jump_if(a, revert);
  }
}

/* The balance of the address at memory 0x40 gets the amount at 0x00 (a
   wrapping ADD). */
static void credit(Asm *a) {
  mload(a, 0x00);
  mload(a, 0x40);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_ADD);
  mload(a, 0x40);
  asm_op(a, EVM_OP_SSTORE);
}

/* The test token of S7 s4 (Q-S7-7 (a)) for the restrict chain gate: the
   smallest ERC-3643 token that calls the compliance contract. The balance of
   an address is at the slot equal to the address word.
   transfer(address,uint256) (from is the caller) reverts when the amount is
   above the balance of from, calls isVerified(to) and canTransfer(from, to,
   x) and reverts when one of them gives 0, moves (SUB, then ADD: a move to
   the sender keeps the balance), calls transferred(from, to, x) and returns
   the word 1. mint(address,uint256) (any caller) adds the amount to the
   balance of to and calls created(to, x). balanceOf(address) returns the
   balance. A failed call reverts. There is no event. Memory: 0x00 the
   amount, 0x20 from, 0x40 to. Another selector reverts. */
static int test_token(Asm *a, FILE *err) {
  static const uint64_t to[] = {0x40};
  static const uint64_t moved[] = {0x20, 0x40, 0x00};
  static const uint64_t minted[] = {0x40, 0x00};
  asm_init(a);
  Label transfer = asm_label(a);
  Label mint = asm_label(a);
  Label balance = asm_label(a);
  Label revert = asm_label(a);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_CALLDATALOAD);
  asm_push(a, 0xe0);
  asm_op(a, EVM_OP_SHR);
  asm_op(a, EVM_OP_DUP1);
  asm_push(a, 0xa9059cbb);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, transfer);
  asm_op(a, EVM_OP_DUP1);
  asm_push(a, 0x40c10f19);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, mint);
  asm_push(a, 0x70a08231);
  asm_op(a, EVM_OP_EQ);
  asm_jump_if(a, balance);
  asm_jump(a, revert);
  asm_jumpdest(a, transfer);
  asm_op(a, EVM_OP_POP);
  asm_op(a, EVM_OP_CALLER);
  asm_push(a, 0x20);
  asm_op(a, EVM_OP_MSTORE);
  arg(a, 0x04, 0x40);
  arg(a, 0x24, 0x00);
  mload(a, 0x20);
  asm_op(a, EVM_OP_SLOAD);
  mload(a, 0x00);
  asm_op(a, EVM_OP_GT); /* the amount > the balance of from */
  asm_jump_if(a, revert);
  comply(a, 0xb9209e33, to, 1, 1, revert);
  comply(a, 0xe46638e6, moved, 3, 1, revert);
  mload(a, 0x00);
  mload(a, 0x20);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_SUB);
  mload(a, 0x20);
  asm_op(a, EVM_OP_SSTORE);
  credit(a);
  comply(a, 0x8baf29b4, moved, 3, 0, revert);
  return_word(a, 1);
  asm_jumpdest(a, mint);
  asm_op(a, EVM_OP_POP);
  arg(a, 0x04, 0x40);
  arg(a, 0x24, 0x00);
  credit(a);
  comply(a, 0x5f8dead3, minted, 2, 0, revert);
  asm_op(a, EVM_OP_STOP);
  asm_jumpdest(a, balance);
  asm_push(a, 0x04);
  asm_op(a, EVM_OP_CALLDATALOAD);
  asm_op(a, EVM_OP_SLOAD);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_MSTORE);
  asm_push(a, 32);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_RETURN);
  asm_jumpdest(a, revert);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_PUSH0);
  asm_op(a, EVM_OP_REVERT);
  return asm_finish(a, err);
}

static int check_answer(const Asm *a) {
  static const char want[] = "61000d565b602a5f5260205ff35b61000456";
  char text[2 * sizeof want];
  int ok = 2 * a->size + 1 == sizeof want;
  if (ok) to_hex(a->code, a->size, text);
  if (ok && strcmp(text, want) == 0) return 1;
  printf("FAIL answer: the code differs from %s\n", want);
  return 0;
}

/* asm_finish refuses an unbound label, a stray label and a full label table. */
static int check_refusals(FILE *quiet) {
  static Asm a;
  asm_init(&a);
  asm_jump(&a, asm_label(&a));
  int unbound = !asm_finish(&a, quiet);
  asm_init(&a);
  asm_bind(&a, 7);
  int stray = !asm_finish(&a, quiet);
  asm_init(&a);
  for (size_t i = 0; i <= ASM_LABELS; i++) asm_label(&a);
  int full = !asm_finish(&a, quiet);
  if (unbound && stray && full) return 1;
  printf("FAIL refusals: unbound %d, stray %d, full %d\n", unbound, stray, full);
  return 0;
}

/* One row with each scalar type, then the Trap() selector of C-K4-9 (a
   name with no parameters). */
static int abi(FILE *out, FILE *err) {
  static const IrScalar params[] = {IR_SCALAR_NAT, IR_SCALAR_FLAG, IR_SCALAR_U256, IR_SCALAR_ADDR};
  IrFunc fn;
  IrFunc trap;
  memset(&fn, 0, sizeof fn);
  memset(&trap, 0, sizeof trap);
  fn.name = "addPrice";
  fn.params = params;
  fn.param_count = 4;
  trap.name = "Trap";
  return target_abi_line(&fn, out, err) && target_abi_line(&trap, out, err);
}

static int checks(const Asm *runtime) {
  FILE *quiet = fopen("/dev/null", "w");
  int passed = check_keccak("", "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470")
             + check_keccak("abc", "4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45")
             + check_keccak("transfer(address,uint256)", "a9059cbb")
             + check_keccak("transferFrom(address,address,uint256)", "23b872dd")
             + check_keccak("approve(address,uint256)", "095ea7b3")
             + check_keccak("balanceOf(address)", "70a08231")
             + check_answer(runtime)
             + check_refusals(quiet != NULL ? quiet : stderr);
  if (quiet != NULL) fclose(quiet);
  printf("asmtool: %d of %d checks passed\n", passed, CHECKS);
  return passed == CHECKS ? 0 : 1;
}

int main(int argc, char **argv) {
  static Asm runtime;
  static Asm creation;
  static Asm token;
  const char *mode = argc == 2 ? argv[1] : "";
  if (argc > 2) return fputs("usage: asmtool [runtime|creation|abi|mock|token]\n", stderr), 2;
  if (!answer(&runtime, stderr)) return 1;
  if (strcmp(mode, "mock") == 0) return mock(&token, stderr) && asm_write_hex(&token, stdout, stderr) ? 0 : 1;
  if (strcmp(mode, "token") == 0) return test_token(&token, stderr) && asm_write_hex(&token, stdout, stderr) ? 0 : 1;
  if (strcmp(mode, "runtime") == 0) return asm_write_hex(&runtime, stdout, stderr) ? 0 : 1;
  if (strcmp(mode, "creation") == 0) return asm_creation(&creation, &runtime, stderr) && asm_write_hex(&creation, stdout, stderr) ? 0 : 1;
  if (strcmp(mode, "abi") == 0) return abi(stdout, stderr) ? 0 : 1;
  if (argc == 2) return fputs("usage: asmtool [runtime|creation|abi|mock|token]\n", stderr), 2;
  return checks(&runtime);
}
