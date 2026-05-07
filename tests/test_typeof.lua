#!/usr/bin/env luajit
--[[
new fail in ff6/vis.lua:

__SDLMainLuaThread coroutine.resume failed.
invalid character in array on line 1
stack traceback:
	[C]: in function 'ffi.typeof'
	./ff6.lua:197: in local 'arrayType'
	./ff6.lua:2239: in function 'ff6'
	//ff6/vis.lua:26: in main chunk
	[string "main.js:1280:6)"]:216: in function <[string "main.js:1280:6)"]:215>

--]]
local ffi = require 'ffi'

local uint8_t = ffi.typeof'uint8_t'
local function arrayType(baseType, size)
	return ffi.typeof('$['..size..']', baseType)
end
local T1 = arrayType(uint8_t, -(0x03c2fc - 0x03c406))
print(T1)
local T2 = arrayType(uint8_t, -(0x03c406 - 0x040000))
print(T2)
