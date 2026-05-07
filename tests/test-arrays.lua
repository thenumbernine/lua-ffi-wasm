#!/usr/bin/env luajit
local ffi = require 'ffi'
local assert = require 'ext.assert'
local uint24_t = ffi.typeof[[struct __attribute__((packed)) {
	uint16_t lo;
	uint8_t hi;
}]]
assert.eq(ffi.sizeof(uint24_t), 3)
ffi.metatype(uint24_t, {
	__index = {
		value = function(self)
			return bit.bor(self.lo, bit.lshift(self.hi, 16))
		end,
	}
})

local d = ffi.new'char[9]'
for i=0,8 do
	d[i] = i
end
local ptrtype = ffi.typeof('$*', uint24_t)
local addr = 0

local o = ffi.cast(ptrtype, d + addr)[0]
addr = addr + ffi.sizeof(uint24_t)
print(o, o:value())

local o = ffi.cast(ptrtype, d + addr)[0]
addr = addr + ffi.sizeof(uint24_t)
print(o, o:value())

local o = ffi.cast(ptrtype, d + addr)[0]
addr = addr + ffi.sizeof(uint24_t)
print(o, o:value())
