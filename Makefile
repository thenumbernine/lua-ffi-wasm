# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy:

CFLAGS= -Wall -Wextra -DLUA_COMPAT_5_3 -I lua/
#CFLAGS+=  -std=gnu99
LDFLAGS=

############ emcc final:
CFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#CFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
##	-target=wasm64-unknown-emscripten
#LDFLAGS+=- -no-debug -target=wasm64-unknown-emscripten -panic=trap -scheduler=none
#LDFLAGS+= --profiling-funcs
LDFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
#LDFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
#LDFLAGS+= -sEXPORT_ALL=1 # https://stackoverflow.com/a/33206957
LDFLAGS+= -sLINKABLE=1 -sEXPORT_ALL=1 # https://stackoverflow.com/a/33208675
#LDFLAGS+= -sIGNORE_MISSING_MAIN=1 # ... isn't ignoring missing main ...
LDFLAGS+= --no-entry
LDFLAGS+= -sSTANDALONE_WASM	# https://stackoverflow.com/a/70230725
# fun story
# DEFAULT_TO_CXX=1 by default, which converts all the C symbols to C++ symbols and then mangles them into absolute worthlessness
# SO
# if you ever compile ***ANY C CODE*** in emscripten, your symbols ***BECOME TRASH*** without doing this ***AND*** adding `__attribute__((visibility("default")))` to all of them.
LDFLAGS+= -sDEFAULT_TO_CXX=0
CC=emcc
LUA=lua-5.4.7-with-ffi.wasm

############ clang, since emcc is wedging in tons of c++ crap, mangling symbol names, etc
# ... needs libc, or idk where wasm-libc is
#	#CFLAGS+=  --no-standard-libraries
#	CC=clang --target=wasm64 -Wl,--export-all -Wl,--no-entry
#	LUA=lua-5.4.7-with-ffi.wasm

############ local arch testing:
#	CFLAGS+= -O2 -fPIC
#	cc=clang
#	LUA=lua.out	# because 'lua' is a submodule - name in the dir is already used



.PHONY: all clean
all: $(LUA)

clean:
	-rm *.o $(LUA)

# Lua 5.4.7

lapi.o: lua/lapi.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcode.o: lua/lcode.c
	$(CC) $(CFLAGS) -c -o $@ $^

lctype.o: lua/lctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldebug.o: lua/ldebug.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldo.o: lua/ldo.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldump.o: lua/ldump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lfunc.o: lua/lfunc.c
	$(CC) $(CFLAGS) -c -o $@ $^

lgc.o: lua/lgc.c
	$(CC) $(CFLAGS) -c -o $@ $^

llex.o: lua/llex.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmem.o: lua/lmem.c
	$(CC) $(CFLAGS) -c -o $@ $^

lobject.o: lua/lobject.c
	$(CC) $(CFLAGS) -c -o $@ $^

lopcodes.o: lua/lopcodes.c
	$(CC) $(CFLAGS) -c -o $@ $^

lparser.o: lua/lparser.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstate.o: lua/lstate.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstring.o: lua/lstring.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltable.o: lua/ltable.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltm.o: lua/ltm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lundump.o: lua/lundump.c
	$(CC) $(CFLAGS) -c -o $@ $^

lvm.o: lua/lvm.c
	$(CC) $(CFLAGS) -c -o $@ $^

lzio.o: lua/lzio.c
	$(CC) $(CFLAGS) -c -o $@ $^

lauxlib.o: lua/lauxlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lbaselib.o: lua/lbaselib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lcorolib.o: lua/lcorolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ldblib.o: lua/ldblib.c
	$(CC) $(CFLAGS) -c -o $@ $^

liolib.o: lua/liolib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lmathlib.o: lua/lmathlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loadlib.o: lua/loadlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

loslib.o: lua/loslib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lstrlib.o: lua/lstrlib.c
	$(CC) $(CFLAGS) -c -o $@ $^

ltablib.o: lua/ltablib.c
	$(CC) $(CFLAGS) -c -o $@ $^

lutf8lib.o: lua/lutf8lib.c
	$(CC) $(CFLAGS) -c -o $@ $^

linit.o: lua/linit.c
	$(CC) $(CFLAGS) -c -o $@ $^

#lua.o: lua/lua.c
#	$(CC) $(CFLAGS) -c -o $@ $^

# LuaFFI-FB

luaffifb_call.o: luaffifb/call.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ctype.o: luaffifb/ctype.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_ffi.o: luaffifb/ffi.c
	$(CC) $(CFLAGS) -c -o $@ $^

luaffifb_parser.o: luaffifb/parser.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final

$(LUA): \
	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o \
	luaffifb_call.o luaffifb_ctype.o luaffifb_ffi.o luaffifb_parser.o
	#lua.o
	$(CC) $(LDFLAGS) -o $@ $^
