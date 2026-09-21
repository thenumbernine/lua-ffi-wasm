#!/usr/bin/env luajit
-- Narrow integers through libffi, in the two directions callValuePush serves:
-- as a function RETURN (call.c ~line 417) and as an argument handed to a Lua
-- CLOSURE (call.c ~line 615).  The two have different storage conventions and
-- one function reads both, which is what the second half of this file catches.
--
-- RETURNS are widened by libffi into one ffi_arg-sized slot.  Reading them
-- through something wider is wrong wherever sizeof(ffi_arg) is smaller - on
-- wasm32 it is 4 against call.c's __wasm__ CallValue member of int64_t, and a
-- C `return -1` came back as 4294967295 there.  Green on x86_64 either way,
-- since the two widths coincide.
--
-- ⚠ CLOSURE ARGUMENTS are NOT widened to ffi_arg, and the four cb_* checks
-- below FAIL ON x86_64 TODAY, on unmodified upstream:
--     cb_s8    -42     seen as 4294967254   (2^32 - 42)
--     cb_s16   -345    seen as 4294966951
--     cb_s32   -67890  seen as 4294899406
--     cb_u32                                 ok, nothing to lose
-- They are extended to 32 bits, so an 8-byte read picks up a zero-extended
-- value and the sign is gone.  The RETURN round-trips correctly through it,
-- which is why a callback test that only checks the return value sees nothing
-- wrong - that is what the `seen` upvalue below is for.
print'begin narrow_args'
local ffi = require 'ffi'
local assert = require 'ext.assert'

ffi.cdef[[
int8_t   ret_s8();
int16_t  ret_s16();
int32_t  ret_s32();
uint32_t ret_u32();
int32_t  sum3_s32(int32_t a, int32_t b, int32_t c);

int8_t   cb_s8 (int8_t   (*cb)(int8_t  ), int8_t   x);
int16_t  cb_s16(int16_t  (*cb)(int16_t ), int16_t  x);
int32_t  cb_s32(int32_t  (*cb)(int32_t ), int32_t  x);
uint32_t cb_u32(uint32_t (*cb)(uint32_t), uint32_t x);
]]

local lib = ffi.load'./libnarrow_args.so'

-- returns
print'ret_s8'    assert.eq(lib.ret_s8(), -42)
print'ret_s16'   assert.eq(lib.ret_s16(), -345)
print'ret_s32'   assert.eq(lib.ret_s32(), -67890)
print'ret_u32'   assert.eq(lib.ret_u32(), 4294967295)
print'sum3_s32'  assert.eq(lib.sum3_s32(1, -5, 2), -2)

-- closure arguments.  every callback is the identity, so anything other than x
-- arriving is the marshalling, not the callback.  check `seen` and not just the
-- return: the return round-trips even when the argument did not.
local seen
local function identity(x) seen = x return x end

print'cb_s8'
seen = nil
assert.eq(lib.cb_s8(ffi.cast('int8_t (*)(int8_t)', identity), -42), -42)
assert.eq(seen, -42)

print'cb_s16'
seen = nil
assert.eq(lib.cb_s16(ffi.cast('int16_t (*)(int16_t)', identity), -345), -345)
assert.eq(seen, -345)

print'cb_s32'
seen = nil
assert.eq(lib.cb_s32(ffi.cast('int32_t (*)(int32_t)', identity), -67890), -67890)
assert.eq(seen, -67890)

print'cb_u32'
seen = nil
assert.eq(lib.cb_u32(ffi.cast('uint32_t (*)(uint32_t)', identity), 4294967295), 4294967295)
assert.eq(seen, 4294967295)

print'done narrow_args'
