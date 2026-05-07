#!/usr/bin/env luajit
local ffi = require 'ffi'
local cast = ffi.cast
local vp = ffi.typeof'void*'

assert(nil == vp())
assert(vp() == nil)

assert(nil ~= cast(vp,1))
assert(cast(vp,1) ~= nil)

assert(false == rawequal(nil, vp()))
assert(false == rawequal(vp(), nil))
assert(false == rawequal(nil, cast(vp,1)))
assert(false == rawequal(cast(vp,1), nil))
print'DONE'
