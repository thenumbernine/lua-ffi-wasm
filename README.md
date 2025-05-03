Lua + luaffifb + emscripten's SDL / GLES to WASM -- used a browser port of my LuaJIT + OpenGL + SDL framework.

Lua is 100% vanilla Lua 5.4.7.

FFI support is by my [fork](https://github.com/thenumbernine/luaffifb) of the now-archived [luaffifb](https://github.com/facebookarchive/luaffifb) project.

[Emscripten](https://emscripten.org) is providing the WASM compiling as well as the SDL, GLES, LibPNG, etc libraries.

Emscripten is also providing `dlsym` support for the FFI.

This repo contains a Makefile for compiling, the submodules, and the lua-interop layer JavaScript file.

# Compiling:

1) Ensure you have the required packages: Emscripten at the moment, and GNU Make.  Sorry CMake fans.
2) Checkout submodules: `git submodule update --init --recursive`
3) Configure LibFFI with Emscripten on your machine, as described below.
4) `make`

This produces `lua-5.4.7-with-ffi.js` and `lua-5.4.7-with-ffi.wasm`.
A lua/javascript interop layer that sits on top of this can be found in the `lua-interop/` folder.

If you want to validate the C++ build's stability versus regular LuaJIT then you can build it for your native platform by just commenting out the emcc section and uncommenting the clang section.

### Configuring LibFFI

Right now `luaffifb` provides the FFI library to vanilla-Lua, however `luaffifb` itself uses JIT for its C calls.
I am avoiding JIT for the sake of my WASM target platform.  So to get around this I am hacking in [libffi](https://github.com/libffi/libffi) calling into my `luaffifb` port.

Configuring LibFFI:
```
cd libffi
emconfigure autoreconf -v -i
cd src/wasm32
emconfigure ../../configure
```

And of course that's not everything.
The `ffitarget.h` that is generated is bad,
it is missing the `FFI_EXTRA_CIF_FIELDS` macro that should be there,
and for some reason mine has a whole bunch of `ifdef (arch)` stuff that has no bearing on its emscripten target.

So next we just copy the packaged `ffitarget.h` over it:
```
cp ffitarget.h include/
```

And then we add our complex support macro, because the generated one had that, but the builtin one didn't, idk why...

```
echo '#define FFI_TARGET_HAS_COMPLEX_TYPE' >> include/ffitarget.h
```

<hr>

# lua-interop.js

Now that you've got your `lua-5.4.7-with-ffi.js` and `.wasm` files, that's great,
but nobody wants to push bytes back and forth into the WASM API.
The `lua-interopj.s` file is a JavaScript/Lua interop library that sits on top of this.  I tried sticking to Fengari or WasMoon as much as possible.

Initialization:
``` javascript
import {newLua} from '/js/lua-interop.js';
const lua = await newLua({
	//... your Emscripten Module args go here ...
});
lua.newState();	// create your initial lua_State
lua.doString(`
print'Hello, World!'
`);				// run Lua code in JavaScript
```

### JavaScript API:

`lua = newLua(args)` = Create a new `lua` interoperability-layer singleton.
This loads the Emscripten WASM and JS and initializes all other necessary parts.
- `args` are arguments forwarded on to the Emscripten `Module`.  Some noteworthy ones are:
	- `.locateFile` = provide a function that returns the path to the emscripten-built WASM, `/js/lua-5.4.7-with-ffi.wasm` by default.
	- `.print` and `.printErr` redirect to `console.log`.
- Additionally, `args` can accept arguments that are specific to `lua-interop.js`:
	- `.luaJSPath` = provide a string of the path to the emscripten-built JavaScript, `/js/lua-5.4.7-with-ffi.js` by default.

The `lua` singleton has in it:

`lua.lib`, which is the module returned from Emscripten, including all the compiled C functions.  Ex: `lib._lua_gettop`, `lib._malloc`, `lib._dlsym`, etc.
Take note that all the symbols in `lua.lib` that were originally C functions, including those pertaining to Lua, all start with an underscore `_`.
This is purely cosmetic and done by Emscripten (against my will), but I gave up on trying to find which compile flags versus compiling as C++ vs C would remove the underscore, so now it's a feature not a bug.

`lua.lib` contains some fields in addition to those that are C symbols:
- `LUA_*` macro-values from the Lua C headers, i.e. `lib.LUA_OK`, etc.
- `_lua_*` macro-functions from the Lua C headers, i.e. `lib._lua_isnil(x)`, etc.

`lua.newState()` = Create a new Lua state and store it within the `lua` object as `lua.L`.
It also constructs the `require 'ffi'` Lua package via `lib.luaopen_ffi()`, as well as the `require 'js'` package via `lua.luaopen_js()`.

Currently the Lua state is a bit of a singleton, so calling this successive times will ditch the old stored Lua State and whatever else is used with it.

`lua.load(code, [name, mode])` = Compiles the Lua code into a Lua function and returns a JavaScript function wrapping it.  Equivalent of `luaL_loadbufferx` but with conversion of the JavaScript string.

`lua.doString(code, ...args)` = Compiles the Lua code into a Lua function and calls it with `args` passed into it.
This is shorthand for `lua.load(code)(...args)`, except that the overhead of creating an extra JavaScript wrapper is avoided.

`lua._G()` = Returns the Lua `_G` global table to JavaScript.

`lua.push(L, value, [isArrow])` = Push a Lua-proxy of a JavaScript object onto the Lua stack.
- ` L` = the Lua state.
- `value` = the JavaScript value to be pushed.
- `isArrow` = JavaScript has no easy way to distinguish between `function(){}` functions and `()=>{}` functions.  The first have a `this` argument and the second does not.
Setting this `isArrow` parameter to be true tells lua-interop that the value is a JavaScript arrow-function, such that subsequent Lua calls to the function will forward arguments 1:1.
Leaving `isArrow` as false, the default value, tells lua-interop that the first argument of all Lua calls to JavaScript is used as its `this` parameter in JavaScript.

`lua.tojs(L, index)` = Convert the Lua value at stack location `index` into a JavaScript object and return it.

`lua.luaopen_js()` = An internal function, used for setting up the `require 'js'` in the Lua state, called upon `lua.newState()`.

## lua-interop Lua API:

`js = require 'js'` = retrieve the JavaScript API

`js.global` = This is the `window` object in JavaScript.

`js.null` = This token represents `null` in JavaScript, while Lua's `nil` represents `undefined` in JavaScript.

`js.new(class, ...)` = Create a new JavaScript object of class `class`, and constructor args `...` and return it to the Lua API.

`js.tonumber(x)` = Cast a value to a number using JavaScript.

`js.tostring(x)` = Cast a value to a string using JavaScript.

`js.instanceof(a,b)` = Returns JavaScript evaluation of `a instanceof b` .

`js.typeof(x)` = Returns JavaScript evaluation of `typeof(x)`.

TODO:
- `js.of`

# JavaScript/Lua conversion:

|                Lua | |         JavaScript |
|--------------------|-|--------------------|
|              `nil` |↔|        `undefined` |
|          `js.null` |↔|             `null` |
|          `boolean` |↔|          `boolean` |
|  `number` / double |→|           `number` |
|  `number` / int64* |→|           `bigint` |
|           `number` |←|           `number` |
|   `number` / int64 |←|         `bigint`** |
|           `string` |↔|           `string` |
|            `table` |→|     `Proxy` object |
|         `function` |→|     `Proxy` object |
|      `table` proxy |←|           `object` |
|      `table` proxy |←|         `function` |
|         `userdata` |→| `{userdata:<ptr>}` |
|           `thread` |→|   `{thread:<ptr>}` |

- *Converting Lua integers to JavaScript: If the value is finite and within `MAX_SAFE_INTEGER` then a `number` will be used, otherwise a `BigInt` will be used.
- **Converting JavaScript BigInts to Lua: BigInt is supposed to be arbitrary-precision, so it deserves a proper library like [LibBF](https://bellard.org/libbf/) or [GMP](https://gmplib.org/) or something.  In the mean time I'll just save them as Lua-integers, which under this build seem to be 64bit.
	BigInts converted to Lua will get truncated to Lua's internal `lua_Integer` type.  That seems to be `int64` at the moment.
- String conversion between JavaScript and Lua is with Emscripten's `stringToNewUTF8` / `UTF8ToString`.
	- Converting from JavaScript to Lua uses `lua_pushstring`, which relies upon null-termination.  I'll switch to `lua_pushlstring` once I figure out how to get the size of stringToNewUTF8's.
- JavaScript objects/functions are exposed to Lua using either the `str_luaWrapObjectMT` or the `str_luaWrapFuncMT` metatables.
	- `__index` to read JavaScript object/function fields.
		- Indexing Keys are as-is.  I don't +1 -1 to make the indexes of one match the environment/language of the other.  Maybe I will write some kind of Array wrapper in each Lua and JavaScript environment for this interoperability.  Maybe `isArrow` will become a collection of serialization arguments.
	- `__newindex` to write JavaScript object/function fields.
	- `__call` to call the JavaScript object/function.
		- By default, the first function argument from Lua is used as the JavaScript function call's `this` argument.  (`str_luaWrapObjectMT` behavior)
			You can disable this when pushing the JavaScript function to Lua via `lua.push` by setting the `isArrow` argument to true.
			Then the first Lua function argument will be passed to the first JavaScript function argument (`str_luaWrapFuncMT` behavior).
	- `__len` to read the `.length` property of the JavaScript object/function.
	- `__pairs` to iterate over JavaScript properties.  Currently is lazy implementation that just caches `Object.keys` and pushes a new lambda that iterates over them.
- Lua objects/functions are exposed to JavaScript using JavaScript `Proxy`.
	- Proxy `get` to read Lua object/function fields.
	- Proxy `set` to write Lua object/function fields.
	- Proxy `apply` to call the Lua object/function.
		- JavaScript args are passed to Lua args.  The JavaScript `this` of the proxy object is not used.
		- The JavaScript function will always return an array of the return values, or return `undefined` if no values were returned.
			This is because JavaScript doesn't support multiple-return, and if I decided to only unwrap single-return results then returning `{{1,2}}` versus `1,2` would be ambiguous.

<hr>

# Motivations / Previous Considerations:

### Lua WASM ports:

I first tried to port my luajit framework to browser with Fengari (easy to integrate but limited features)
and then Wasmoon (a bit better features but horrible to integrate).
But in both I was using a pure-lua implementation of ffi which runs slow.

What else I tried before I came to this option:

- Fengari
	- Pro: JavaScript interop is flawless.
	- Con: There's no `__gc` overloading since JavaScript handles the object lifespan (at least I think that's why).  Sadly my Lua GL library frees resources upon `__gc`, so that means GL resources won't get automatically freed.  Neither will FFI memory ... so better not leak anything!
	- Con: no FFI

- Wasmoon
	- Pro: ...is Emscripten-compiled and so you do get Emscripten's filesystem for free, however everything Wasmoon itself brings to the table makes things more difficult.
	- Con: The Wasmoon wrapping filesystem calls are all in TEXT, not BINARY, so I have to side-step them.
	- Pro: Overriding Emscripten's print and printErr is straightforward without Wasmoon ... but is a pain to do with it (haven't figured out how yet)
	- Con: The Wasmoon interop functions are full of holes.
		- There's strange cases where my own classes and objects will be passed through fine, but builtin functions like `ArrayBuffer` when passed through will get extra crap wrapped around them.
		- Lua calls to JavaScript code will detect different objects every time for the same Lua object (or for the same original JavaScript object even),
		- Wasmoon doesn't give any meaningful errors in Lua, just "Error: Error".  So all my lua code entry points need to be wrapped in xpcall's.
		- Wasmoon doesn't give any meaningful errors in JavaScript code called by Lua, just something about `TypeError: Cannot read properties of null (reading 'then')`, so all Lua-to-JavaScript calls need to be wrapped in try/catch blocks.
		- Wasmoon Lua-to-JavaScript calls cannot `await`.
	- Con: no FFI

- Other contenders?
	- https://github.com/Doridian/LuaJS

### Lua-FFI libraries:

I settled on LuaFFIFB because its parser seemed the most feature-complete, namely that it can parse bitfields, however I looked over and tried a few others, and here's my thoughts on them all:

- My original pure-Lua [`ffi.lua`](https://github.com/thenumbernine/glapp-js/blob/64b297b21041f1d3e3d675058b8d2adfc39c0d1d/ffi.lua)
	- Only handles types and allocations within WASM. I hadn't got EMCC DLSym support working at the time so I didn't bother write in function prototype support.
	- Pro: Bitfields.
- https://github.com/facebookarchive/luaffifb
	- Pro: Best parser, including bitfields, attributes, etc.
	- Con: FFI based calling.  This means it's the fastest on native machines, but it sadly means no WASM support for the original calls.  I had to replace them in my own fork.
- https://github.com/q66/cffi-lua
	- Pro: LibFFI based calling.  This is slow for native arch, but this is flexible, and LibFFI now supports WASM, so this is ultimately what I wanted.
	- Pro: Much much much cleaner code than LuaFFIFB.
	- Con: No bitfield support
- https://github.com/zhaojh329/lua-ffi - successor to https://github.com/q66/cffi-lua
	- Pro: LibFFI based calling.
	- Pro: Also very clean code, easy to work with.
	- +/-: No bitfield support?  No complex support?
	- Pro: Development is still active, I am optimistic and maybe I will swap my luaffifb out with this at some point.
- https://github.com/thenumbernine/luaffifb - My fork of LuaFFIFB.
	- Pro: Using LuaFFIFB's parser, which is a good one.  Bitfields, align, attributes, etc are all supported.
	- Con: Pointers can only be 3 levels deep.  LibJPEG even breaks this.  I will replace it with something more flexible eventually.
	- Pro: I wedged in LuaFFI calling.
	- Con: No C callback objects via LuaFFI calling just yet...

# MAKEFILE TODO:

- why are there underscores before all my symobl names? there weren't when i outputted pure wasm (and missed out on the filesystem).  I see emscripten is manaully inserting them in the exports: `Module['_luaL_addstring'] = wasmExports['luaL_addstring']`.  WHYYYYY?  I'll manually remove them if I have to.  Maybe later I'll switch to pure-wasm.
- outputting pure wasm.  I'm outptting js+wasm now because this seems to be the only way to get emscripten's virtual filesystem.  switching to wasm output makes FS go away.
- switch over to just clang + some other libc like wasi, or maybe even just take emscripten's C lib ports (musl, sdl, libpng, etc) and build them myself while avoiding the emscripten JavaScript 100%.
