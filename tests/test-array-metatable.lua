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

-- [[ now for array types ... this fails in luajit
local A4 = ffi.typeof('$[4]', A)
print(A4)
assert.error(function()
	-- this should error because it __indexes a field in a ctype that isn't there
	-- and in luajit it is a error-worthy offense to __index a cdata/ctype field that isn't there.
	print(A4.test)
end)
assert.error(function()
	assert.eq(A4.test, A.test)
end)
local a4 = A4()
assert.error(function()
	print(a4.test)
end)
assert.error(function()
	-- this will pass in bugged luaffifb because it gives array types their ctype metatables
	assert.eq(a4.test, A.test)
end)
--]]


local mt4
assert.error(function()
	-- luajit gives: "bad argument #1 to 'metatype' (invalid C type)"
	-- so luajit can't metatype an array type (which I think is good)
	mt4 = ffi.metatype(A4, {
		__index = {
			test2 = function(self)
				print('can luajit give array types separate metatypes?')
				return 43
			end,
		}
	})
end)
assert.error(function()
	-- all these pass in bugged luaffifb
	print(A4.test2)
end)
