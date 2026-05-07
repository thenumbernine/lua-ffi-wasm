#!/usr/bin/env luajit
local ffi = require 'ffi'
local assert = require 'ext.assert'

-- make sure type-params work

local int = ffi.typeof'int'
local int8_t = ffi.typeof'int8_t'
local int16_t = ffi.typeof'int16_t'
local int32_t = ffi.typeof'int32_t'
local int64_t = ffi.typeof'int64_t'
local uint8_t = ffi.typeof'uint8_t'
local uint16_t = ffi.typeof'uint16_t'
local uint32_t = ffi.typeof'uint32_t'
local uint64_t = ffi.typeof'uint64_t'

assert.eq(int, int32_t)
assert.eq(ffi.sizeof(int), 4)
assert.eq(ffi.typeof(int), int)

local int_2nd = ffi.typeof('$', int)
assert.eq(int, int_2nd)

-- make sure structs can use them
-- use arrays since the numbers themselves would be converted to lua numbers
local int8_1 = ffi.typeof('$[1]', int8_t)
local int8_ref_1 = ffi.typeof('$(&)[1]', int8_t)	-- TODO support for refs-to-arrays in luaffifb...
local int16_1 = ffi.typeof('$[1]', int16_t)
local int16_ref_1 = ffi.typeof('$(&)[1]', int16_t)
local int32_1 = ffi.typeof('$[1]', int32_t)
local int32_ref_1 = ffi.typeof('$(&)[1]', int32_t)
local int64_1 = ffi.typeof('$[1]', int64_t)
local int64_ref_1 = ffi.typeof('$(&)[1]', int64_t)

ffi.cdef([[
typedef struct {
	$ a;
	$ b;
} A;
]], int16_1, int64_1)

local A = ffi.typeof'A'

local a = A()
assert.eq(ffi.typeof(a), A)
assert.eq(ffi.typeof(a.a), int16_ref_1)
assert.eq(ffi.typeof(a.b), int64_ref_1)
assert.eq(ffi.sizeof(A), 16)

-- try again but with anonymous type
local B = ffi.typeof([[struct {
	$ a;
	$ b;
}]], int8_1, int32_1)

local b = B()
assert.eq(ffi.typeof(b), B)
assert.eq(ffi.typeof(b.a), int8_ref_1)
assert.eq(ffi.typeof(b.b), int32_ref_1)
assert.eq(ffi.sizeof(B), 8)

local C = ffi.typeof([[struct { $ a, b; $ c, d; }]], A, B)
assert.eq(ffi.offsetof(C, 'a'), 0)
assert.eq(ffi.offsetof(C, 'b'), 16)
assert.eq(ffi.offsetof(C, 'c'), 32)
assert.eq(ffi.offsetof(C, 'd'), 40)
assert.eq(ffi.sizeof(C), 48)
