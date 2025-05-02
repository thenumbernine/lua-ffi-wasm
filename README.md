For building Lua + luaffifb to wasm for the browser port of my LuaJIT + OpenGL + SDL framework.

Lua is 100% vanilla Lua 5.4.7.

FFI will be provided to Lua from my [fork](https://github.com/thenumbernine/luaffifb) of the now-archived [luaffifb](https://github.com/facebookarchive/luaffifb) project.

So here's just the Makefile for building Lua 5.4 + LuaFFI + whatever other libraries all directly into emscripten wasm.

# Compiling:

1) Ensure you have the required packages: Emscripten at the moment, and GNU Make.  Sorry CMake fans.
2) Checkout submodules: `git submodule update --init --recursive`
3) configure LibFFI for your machine, as below
4) `make`

This produces `lua-5.4.7-with-ffi.js` and `lua-5.4.7-with-ffi.wasm`.
A lua/javascript interop layer that sits on top of this can be found in the `lua-interop/` folder.

If you want to validate the C++ build's stability versus regular LuaJIT then you can build it for your native platform by just commenting out the emcc section and uncommenting the clang section.

### LibFFI

I am using luaffifb, but it invokes calls with JIT, which I'm avoding / can't do courtesy of WASM target.  My fix, to use LibFFI with luaffifb.

Configuring:
```
cd libffi
emconfigure autoreconf -v -i
cd src/wasm32
emconfigure ../../configure
```

J/k that's not enough, the `ffitarget.h` that is generated is bad, it is missing the `FFI_EXTRA_CIF_FIELDS` that should go in there, and for some reason mine has a whole bunch of `ifdef (arch)` stuff that has no bearing on emscripten.
So now we just copy the packaged `ffitarget.h` over it.

```
cp ffitarget.h include/
```

And then we add our complex upport macro, cuz the generated one had that, but the builtin one didn't, idk why..

```
echo '#define FFI_TARGET_HAS_COMPLEX_TYPE' >> include/ffitarget.h
```

<hr>

# lua-interop.js

Now that you've got your `lua-5.4.7-with-ffi.js` and `.wasm` files, that's great, but who is going to just push bytes into WASM?
The `lua-interopj.s` file is a JS/Lua interop library that sits on top of this.  I tried sticking to Fengari or WasMoon as much as possible.

Initialization:
``` javascript
import {newLua} from '/js/lua-interop.js';
const lua = await newLua({
	//... your Emscripten Module args go here ...
});
lua.newState();	// create your initial lua_State
lua.doString(`
print'Hello, World!'
`);				// run Lua code in JS
```

## lua-interop JS API:

Emscripten Module defaults set specifically by `lua-interop.js`:
- `.locateFile` looks in `/js/lua-5.4.7-with-ffi.wasm`
- `.print` and `.printErr` redirect to `console.log`

`lua` includes in it:
- `lua.lib`, which is the module returned from Emscripten.
Take note that all the symbols in `lua.lib` that were originally C functions, including those pertaining to Lua, all start with an underscore `_`.
If you open the `lua-5.4.7-with-ffi.js` file then you will see this is purely cosmetic and done by Emscripten (against my will), but I gave up on trying to find which compile flags versus compiling as C++ vs C would remove the underscore, so now it's a feature not a bug.

I've added to `lua.lib` some additional fields: 
- as many familiar `LUA_*` macro-values as I could muster.
- as many familiar `_lua_*` macro-functions as I could muster.

`lua.newState()` = Create a new Lua state and store it within the `lua` object as `lua.L`.
It also sets up `luaopen_ffi` and all the objects necessary for JS/Lua interop.
If you want to make and use a new `lua_State` but without `luaffi` then feel free to follow the original Lua C API.
Also it sets up `package.loaded.js` to hold our Lua's JS API, such that a `require 'js'` will retrieve it within Lua.
Currently the Lua state is a bit of a singleton, so calling this successive times will ditch the old stored Lua State and whatever else is used with it.

`lua.doString(code, ...args)` = Compiles the Lua code in `code` into a Lua function and calls it with `args` passed into it.
`args` are serialized from JS to Lua, and results are serialized from Lua to JS and returned in a JS Array.  If the Lua function has no results then nothing is returned to JS.

`lua._G()` = Returns the Lua `_G` global table to JavaScript.

`lua.luaopen_js` is an internal function, used for setting up the `require'js'` in the Lua state, called upon `lua.newState()`.

`lua.push_js(L, value, [isArrow])` = Push a Lua-proxy of a JS object onto the Lua stack.
` L` = the Lua state.
- `value` = the value to be pushed.
- `isArrow` = JavaScript has no easy way to distinguish between `function(){}` functions and `()=>{}` functions.  The first have a `this` argument and the second does not.
Setting this `isArrow` parameter to be true tells lua-interop that the value is a JS arrow-function, such that subsequent Lua calls to the function will forward arguments 1:1.
Leaving `isArrow` as false, the default value, tells lua-interop that the first argument of all Lua calls to JS is used as its `this` parameter in JS. 

`lua.lua_to_js(L, index)` = Convert the Lua value at stack location `index` into a JS object and return it.

## lua-interop Lua API:

`js = require 'js'` = retrieve the JS API

`js.global` = This is the `window` object in JavaScript.

`js.null` = This token represents `null` in JavaScript, while Lua's `nil` represents `undefined` in JavaScript.

`js.new(class, ...)` = Create a new JS object of class `class`, and constructor args `...` and return it to the Lua API.

`js.tonumber(x)` = Cast a value to a number using JavaScript.

`js.tostring(x)` = Cast a value to a string using JavaScript.

`js.instanceof(a,b)` = Returns JavaScript evaluation of `a instanceof b` .

`js.typeof(x)` = Returns JavaScript evaluation of `typeof(x)`.

# JS/Lua conversion:

|           Lua |   |                 JS |
|---------------|---|--------------------|
|         `nil` |↔|        `undefined` |
|     `js.null` |↔|             `null` |
|     `boolean` |↔|          `boolean` |
|      `number` |↔|           `number` |
|      `string` |↔|           `string` |
|       `table` |→|     `Proxy` object |
| `table` proxy |←|           `object` |
|    `function` |→|         `function` |
| `table` proxy |←|         `function` |
|    `userdata` |→| `{userdata:<ptr>}` |
|      `thread` |→|   `{thread:<ptr>}` |

- String conversion between JS and Lua is with Emscripten's `stringToNewUTF8` / `UTF8ToString`.
- Lua tables are exposed to JS using a `Proxy` object. These `Proxy` objects support reading and writing fields.
- JS objects/functions are exposed to Lua using a proxy table. These tables support:
	- getters
	- setters
	- the Lua length operator `#` will return the `.length` or `.size` of the JS object, or `0` if neither is found.
	- calls
- Lua functions are converted to JS functions.  Writing to subsequent fields of a Lua function from within JS will not reflect a written field in the Lua function object.  At least until I figure out how to do JS proxy call operations.

<hr>

# Motivations / Previous Considerations:

I first tried to port my luajit framework to browser with Fengari (easy to integrate but limited features)
and then Wasmoon (a bit better features but horrible to integrate).
But in both I was using a pure-lua implementation of ffi which runs slow.

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

# MAKEFILE TODO:

- outputting pure wasm.  I'm outptting js+wasm now because this seems to be the only way to get emscripten's virtual filesystem.  switching to wasm output makes FS go away.
- dlsym doesn't work, so no functions in `ffi.cdef` work
- replace the lua webgl-gles3 layer with a C one and use luaffi to link to it.  this has a few pain points:
	1) I don't think I've got ffi to dlsym into anything.  I don't think I've seen emscripten's dlsym work whatsoever, it only ever returns 0's, even for functions that are there and are exported and are being used.
	2) emscripten has its own binding layer, but when I enable `FULL_ES3` and export, say, `glEnable`, it gives me back JS code - not wasm code with a symbol.
		- Maybe this is because I'm outputting JS+WASM, and that means I have to switch back to pure-WASM
- same with emscripten's ZLIB layer, but when I set `USE_ZLIB` I still don't see any zlib symbols...
- same with emscripten's SDL layer
- why are there underscores before all my symobl names? there weren't when i outputted pure wasm (and missed out on the filesystem).  I see emscripten is manaully inserting them in the exports: `Module['_luaL_addstring'] = wasmExports['luaL_addstring']`.  WHYYYYY?  I'll manually remove them if I have to.  Maybe later I'll switch to pure-wasm.
- memory problems.  I tried `-mmemoryprofiler`, but all I see is an empty block "include memoryprofiler.js end include memoryprofiler.js" ...
