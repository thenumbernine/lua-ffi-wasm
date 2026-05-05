#!/usr/bin/env luajit
local ffi = require 'ffi'

ffi.cdef[[
// I think packed got flagged but not used ...
struct __attribute__((packed)) A {
	double c;
	char b;
};
]]

print('sizeof A', ffi.sizeof'struct A')
