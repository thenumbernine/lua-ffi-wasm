#!/usr/bin/env luajit
local ffi = require 'ffi'
local assert = require 'ext.assert'
local A = ffi.typeof[[ struct { int a; }]]
local mtA = ffi.metatype(A, {
	__index = {
		test = function(self)
			print('calling A:test() with A.a=='..self.a)
			return self.a * self.a + 1
		end,
	},
})

print(A)
assert(A.test)	-- in luajit, ctype __index can access its metatable __index
print(A.test)
--print(A:test()) -- ofc this will error since a ctype doesn't have the fields that its instance does...
assert.eq(2*2+1, A.test{a=2})	-- but faking the fields with a lua table will circumvent this

local a = A()	-- the real deal
assert.eq(a.test, A.test)
a.a = 3
assert.eq(3*3+1, a:test())
a.a = 4
assert.eq(4*4+1, A.test(a))

-- now for array types ...
local A4 = ffi.typeof('$[4]', A)
print(A4)
print(A4.test)
assert.eq(A4.test, A.test)
local a4 = A4()
print(a4.test)
assert.eq(a4.test, A.test)
