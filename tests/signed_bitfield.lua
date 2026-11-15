#!/usr/bin/env luajit
local ffi = require 'ffi'

print'int8'
ffi.cdef[[
typedef union {
	struct {
		uint8_t a1 : 4;
		int8_t a2 : 4;
	};
	struct {
		int8_t b1 : 4;
		uint8_t b2 : 4;
	};
} Test8;
]]

local a = ffi.new'Test8'
a.a1 = 14
print('a1', a.a1)
print('b1', a.b1)
assert(a.b1 == -2)
a.a2 = -6
print('a2', a.a2)
print('b2', a.b2)
assert(a.b2 == 10)

print'int16'
ffi.cdef[[
typedef union {
	struct {
		uint16_t a1 : 8;
		int16_t a2 : 8;
	};
	struct {
		int16_t b1 : 8;
		uint16_t b2 : 8;
	};
} Test16;
]]

local a = ffi.new'Test16'
a.a1 = 243
print('a1', a.a1)
print('b1', a.b1)
assert(a.b1 == -13)
a.a2 = -120
print('a2', a.a2)
print('b2', a.b2)
assert(a.b2 == 136)

print'int32'
ffi.cdef[[
typedef union {
	struct {
		uint32_t a1 : 16;
		int32_t a2 : 16;
	};
	struct {
		int32_t b1 : 16;
		uint32_t b2 : 16;
	};
} Test32;
]]

local a = ffi.new'Test32'
a.a1 = 43210
print('a1', a.a1)
print('b1', a.b1)
assert(a.b1 == -22326)
a.a2 = -20000
print('a2', a.a2)
print('b2', a.b2)
assert(a.b2 == 45536)

--[=[
-- luajit fails: invalid value
-- luaffifb doesn't convert cdata to int and then fails to compare them
print'int64'
ffi.cdef[[
typedef union {
	struct {
		uint64_t a1 : 32;
		int64_t a2 : 32;
	};
	struct {
		int64_t b1 : 32;
		uint64_t b2 : 32;
	};
} Test64;
]]

local a = ffi.new'Test64'
a.a1 = 36028797018963968ULL
print('a1', a.a1)
print('b1', a.b1)
print('a2', a.a2)
print('b2', a.b2)
--]=]
