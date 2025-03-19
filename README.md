For building Lua + luaffifb to wasm for the browser port of my LuaJIT + OpenGL + SDL framework.

I first tried to port my luajit framework to browser with Fengari (easy to integrate but limited features)
and then Wasmoon (a bit better features but horrible to integrate).
But in both I'm using a pure-lua implementation of ffi which runs slow.

So here's me trying to build Lua 5.4 + LuaFFI + whatever other libraries all directly into emscripten.
