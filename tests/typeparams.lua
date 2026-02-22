#!/usr/bin/env luajit
local ffi = require 'ffi'

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

assert(int == int32_t)
assert(ffi.sizeof(int) == 4)
assert(ffi.typeof(int) == int)

local int_2nd = ffi.typeof('$', int)
assert(int == int_2nd)

-- make sure structs can use them
local int16_1 = ffi.typeof('$[1]', int16_t)	-- use arrays since the numbers themselves would be converted to lua numbers
local int64_1 = ffi.typeof('$[1]', int64_t)	-- use arrays since the numbers themselves would be converted to lua numbers

ffi.cdef([[
typedef struct {
	$ a;
	$ b;
} A;
]], int16_1, int64_1)

local A = ffi.typeof'A'

local a = A()
assert(ffi.typeof(a) == A)
assert(ffi.typeof(a.a), int16_1)
assert(ffi.typeof(a.b), int64_1)

-- try again but with anonymous type
local B = ffi.typeof([[struct {
	$ a;
	$ b;
}]], int16_1, int64_1)

local b = B()
assert(ffi.typeof(b) == B)
assert(ffi.typeof(b.a), int16_1)
assert(ffi.typeof(b.b), int64_1)

assert(ffi.sizeof(A) == ffi.sizeof(B))
