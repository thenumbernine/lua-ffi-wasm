#!/usr/bin/env luajit
local ffi = require 'ffi'

cb = function(s)
	print('in callback')
	print('arg type', ffi.typeof(s))
	print('arg contents', s)
	print('arg as string', ffi.string(s))
	return 42
end

cl = ffi.cast('int (*)(char const *)', cb)

s = 'testing'
arg = ffi.cast('char const *', s)
r = cl(s)
print('out of callback with result', r)
