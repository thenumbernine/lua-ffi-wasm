#!/usr/bin/env lua
require 'ext'
require 'ext.cmdline'.validate{
	injs = {
		desc = 'input js filename',
		must = true,
	},
	inwasm = {
		desc = 'input wasm filename',
		must = true,
	},
	outjs = {
		desc = 'output js filename',
		must = true,
	},
	outwasm = {
		desc = 'output wasm filename',
		must = true,
	},
}(...)
local fp = path(cmdline.injs)
local d = assert(fp:read()):trim()

-- remove old code header
local oldheader = ([[
var lua = (() => {
  var _scriptName = typeof document != 'undefined' ? document.currentScript?.src : undefined;
  
  return (
async function(moduleArg = {}) {
  var moduleRtn;
]]):trim()
d = assert(d:gsub('^'..oldheader:patescape(), ''), "replace-header has changed")

-- remove old code footer
local oldfooter = ([[
moduleRtn=readyPromise;


  return moduleRtn;
}
);
})();
if (typeof exports === 'object' && typeof module === 'object') {
  module.exports = lua;
  // This default export looks redundant, but it allows TS to import this
  // commonjs style module.
  module.exports.default = lua;
} else if (typeof define === 'function' && define['amd'])
  define([], () => lua);
]]):trim()
d = assert(d:gsub(oldfooter:patescape()..'$', ''), "replace-footer has changed")

-- add new header and footer
d = [[
var _scriptName = typeof document != 'undefined' ? document.currentScript?.src : undefined;
  
const moduleArg = {};

]] .. d:trim() .. [[


export { Module as lua };
]]

-- replace the wasm path 
-- dist name here
local count
d, count = d:gsub((('%q'):format(cmdline.inwasm)):patescape(), 'wasmPath')
assert.eq(count, 1, "failed to find wasm destname")
d = [[
const wasmPath = ]]..('%q'):format(cmdline.outwasm)..[[;
]] .. d

assert(path(cmdline.outjs):write(d))
