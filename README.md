For building Lua + luaffifb to wasm for the browser port of my LuaJIT + OpenGL + SDL framework.

Lua is 99.99% vanilla Lua 5.4.7.

FFI is from my [fork](https://github.com/thenumbernine/luaffifb) of the now-archived [luaffifb](https://github.com/facebookarchive/luaffifb) project.

I first tried to port my luajit framework to browser with Fengari (easy to integrate but limited features)
and then Wasmoon (a bit better features but horrible to integrate).
But in both I'm using a pure-lua implementation of ffi which runs slow.

So here's just the Makefile for building Lua 5.4 + LuaFFI + whatever other libraries all directly into emscripten wasm.

It outputs `lua-5.4.7-with-ffi.js` and `lua-5.4.7-with-ffi.wasm`.

If you want a good lua/javascript interop to sit on top of it, check out https://github.com/thenumbernine/js-util where I'm saving the dist files alongside `lua-interop.js` which does this.

If you want to validate the C++ build's stability versus regular LuaJIT then you can build it for your native platform by just commenting out the emcc section and uncommenting the clang section.

What else I tried before I came to this option:

- Fengari
	- Pro: JS interop is flawless.
	- Con: There's no `__gc` overloading since JS handles the object lifespan (at least I think that's why).  Sadly my Lua GL library frees resources upon `__gc`, so that means GL resources won't get automatically freed.  Neither will FFI memory ... so better not leak anything!
	- Con: no FFI

- Wasmoon
	- Pro: ...is Emscripten-compiled and so you do get Emscripten's filesystem for free, however everything Wasmoon itself brings to the table makes things more difficult.
	- Con: The Wasmoon wrapping filesystem calls are all in TEXT, not BINARY, so I have to side-step them.
	- Pro: Overriding Emscripten's print and printErr is straightforward without Wasmoon ... but is a pain to do with it (haven't figured out how yet)
	- Con: The Wasmoon interop functions are full of holes.
		- There's strange cases where my own classes and objects will be passed through fine, but builtin functions like `ArrayBuffer` when passed through will get extra crap wrapped around them.
		- Lua calls to JS code will detect different objects every time for the same Lua object (or for the same original JS object even),
		- Wasmoon doesn't give any meaningful errors in Lua, just "Error: Error".  So all my lua code entry points need to be wrapped in xpcall's.
		- Wasmoon doesn't give any meaningful errors in JS code called by Lua, just something about `TypeError: Cannot read properties of null (reading 'then')`, so all Lua-to-JS calls need to be wrapped in try/catch blocks.
		- Wasmoon Lua-to-JS calls cannot `await`.
	- Con: no FFI

- Other contenders?
	- https://github.com/Doridian/LuaJS

# TODO

- `ffi.null` as well as `ffi.NULL`
- luaffifb C type objects (ffi.typeof / ffi.metatype results) don't also to their object's metatable, especially `__index`. This is not the case in LuaJIT.
- `print(ffi.cast('void*', ffi.cast('vec3f_t*', 0)+1))` should show `0xc`, but instead it shows `vec3f(1,1,1)` ... an error in luaffifb with its cdata of pointers' metamethods, esp +, is treating the pointer as its data when it should be doing pointer-arithmetic.
