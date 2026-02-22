# output of the Makefile-native lua-ffi-wasm root folder 
LUA= ../lua.out

CFLAGS+= -fPIC -Wall

HOST_SYS:= $(shell uname -s)
ifeq (Linux,$(HOST_SYS))
	LDFLAGS+= -shared
else	# if OSX ...
	LDFLAGS+= -dynamiclib -undefined dynamic_lookup -flat_namespace
endif

ifeq ($(DEBUG),1)
	# debug
	CFLAGS+= -DDEBUG -O0 -gdwarf-2 -mfix-and-continue
	TEST_CMD=        echo 'bt' > lldb.batch && lldb --batch -K lldb.batch -o run -f $(LUA) -- test.lua
	SIMPLE_TEST_CMD= echo 'bt' > lldb.batch && lldb --batch -K lldb.batch -o run -f $(LUA) -- simple_test.lua
else
	# release
	CFLAGS+= -DNDEBUG -O2
	TEST_CMD= $(LUA) test.lua
	SIMPLE_TEST_CMD= $(LUA) simple_test.lua
endif

all: libtest.so libsimple_test.so align

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

#.so for lua to link into
libtest.so: test.o
	$(CC) $(LDFLAGS) -o $@ $^

#.so for lua to link into
libsimple_test.so: simple_test.o
	$(CC) $(LDFLAGS) -o $@ $^

# standalone for verifying lua's results
align: align.o
	$(CC) -o $@ $^

.PHONY: clean
clean:
	rm -f *.o *.so *.dylib

.PHONY: test
test: libtest.so libsimple_test.so
	$(TEST_CMD)

.PHONY: simple_test
simple_test: ffi.so libsimple_test.so
	$(SIMPLE_TEST_CMD)
