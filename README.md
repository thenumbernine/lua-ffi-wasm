Here's the WASM side of my LuaJIT + OpenGL + SDL in Browser

The client side attempted Fengari (easy to integrate but limited features) and then Wasmoon (a bit better features but horrible to integrate).
But in both I'm using a pure-lua implementation of ffi which runs slow.

So here's me trying to build Lua 5.4 + LuaFFI + whatever other libraries all diretcly into emscripten.
