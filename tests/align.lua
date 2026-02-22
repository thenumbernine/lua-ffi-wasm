#!/usr/bin/env luajit
local ffi = require 'ffi'
	
print("offsetof(a) offsetof(b) sizeof()")

ffi.cdef[[
typedef struct S1 {
	uint8_t a;
	uint8_t b;
} S1;
]]
print('S1', ffi.offsetof('S1', 'a'), ffi.offsetof('S1', 'b'), ffi.sizeof'S1')
	
-- alignof per field
ffi.cdef[[
typedef struct S2 {
	uint8_t __attribute__((__aligned__(8))) a;
	uint8_t __attribute__((__aligned__(8))) b;
} S2;
]]
print('S2', ffi.offsetof('S2', 'a'), ffi.offsetof('S2', 'b'), ffi.sizeof'S2')
	
-- alignof per composite field
ffi.cdef[[
typedef struct S3 {
	uint8_t __attribute__((__aligned__(8))) a, b;
} S3;
]]
print('S3', ffi.offsetof('S3', 'a'), ffi.offsetof('S3', 'b'), ffi.sizeof'S3')
	
-- alignof per field with expression
ffi.cdef[[
typedef struct S4 {
	uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a;
	uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) b;
} S4;
]]
print('S4', ffi.offsetof('S4', 'a'), ffi.offsetof('S4', 'b'), ffi.sizeof'S4')

-- alignof per composite field
ffi.cdef[[
typedef struct S5 {
	uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a, b;
} S5;
]]
print('S5', ffi.offsetof('S5', 'a'), ffi.offsetof('S5', 'b'), ffi.sizeof'S5')
