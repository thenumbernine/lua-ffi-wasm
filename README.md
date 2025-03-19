For building Lua + luaffifb to wasm for the browser port of my LuaJIT + OpenGL + SDL framework.

I first tried to port my luajit framework to browser with Fengari (easy to integrate but limited features)
and then Wasmoon (a bit better features but horrible to integrate).
But in both I'm using a pure-lua implementation of ffi which runs slow.

So here's just the Makefile for building Lua 5.4 + LuaFFI + whatever other libraries all directly into emscripten wasm.

It outputs `lua-5.4.7-with-ffi.js` and `lua-5.4.7-with-ffi.wasm`.

If you want a good lua/javascript interop to sit on top of it, check out https://github.com/thenumbernine/js-util where I'm saving the dist files alongside `lua-interop.js` which does this.

If you want to validate the C++ build's stability versus regular LuaJIT then you can build it for your native platform by just commenting out the emcc section and uncommenting the clang section.
