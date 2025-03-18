# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy: 

CFLAGS=-std=gnu99 -O2 -Wall -Wextra -DLUA_COMPAT_5_3 -fPIC
CFLAGS+= -I lua/

# emcc final:
#CC=emcc
#LUA=lua.wasm

# local arch testing:
cc=clang
LUA=lua.out	# because 'lua' is a submodule - name in the dir is already used

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

lua.o: lua/lua.c
	$(CC) $(CFLAGS) -c -o $@ $^

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

$(LUA):  lua.o \
	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o \
	luaffifb_call.o luaffifb_ctype.o luaffifb_ffi.o luaffifb_parser.o
	$(CC) $(LDFLAGS) -o $@ $^

#ar rcu liblua.a lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o 
#ranlib liblua.a
#
#gcc -std=gnu99 -shared -ldl -o liblua.5.4.7.so lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o -lm  # -Wl,-soname,liblua5.4.7.so
#
#ln -sf liblua.5.4.7.so liblua.so
#
#gcc -std=gnu99 -o lua   lua.o liblua.a -lm -lreadline 
#
#luac.o: luac.c
#	$(CC) $(CFLAGS) $@ $^
#
#gcc -std=gnu99 -o luac   luac.o liblua.a -lm -lreadline 

