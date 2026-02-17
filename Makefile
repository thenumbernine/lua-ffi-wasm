# I thought github.com/lua/lua would be ... lua ... but, welp, the Makefiles are missing
# I'm too lazy to hunt down wherever the Makefile are developed, so here's my lazy copy:

include Files.mk


# libffi has its own emscripten configure and build
# but what it spits out isn't "relocatable" i.e. I can't just link it below
# so here's what I found in the libffi/src/wasm/Makefile:
LIBFFI_SRCS = $(patsubst %, libffi/%, \
	src/prep_cif.c \
	src/types.c \
	src/raw_api.c \
	src/java_raw_api.c \
	src/closures.c \
	src/tramp.c \
	src/debug.c \
	src/wasm/ffi.c \
)
LIBFFI_CFLAGS = -I libffi/src/wasm/include/ -I libffi/src/wasm -I libffi/include

# luaffifb will use libffi
LUAFFIFB_CFLAGS += -I libffi/src/wasm/include -I libffi/src/wasm

# https://stackoverflow.com/a/23324703/2714073
#CWD := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
# just dont run make from another dir ...
CWD = $(strip $(shell pwd))

# I could put this in Files.mk, but the native binary can also just ffi.load cimgui, so why static-link it? so put it here.
CIMGUI_SRCS = $(patsubst %, cimgui/%, \
	cimgui.cpp \
	imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_demo.cpp imgui/imgui_tables.cpp imgui/imgui_widgets.cpp \
	imgui/backends/imgui_impl_opengl3.cpp imgui/backends/imgui_impl_sdl3.cpp \
)

CIMGUI_CFLAGS = -std=c++20 -DIMGUI_IMPL_API=extern\ \"C\" -I $(CWD)/cimgui -iquote $(CWD)/cimgui/imgui

# how does evaluation work?  do i have to redo DIST_OBJs too? or is expansion deferred or whatever?
DIST_SRCS+= $(LIBFFI_SRCS) $(CIMGUI_SRCS)
DIST_OBJS= $(patsubst %.c, %$(O), \
	$(patsubst %.cpp, %$(O), $(DIST_SRCS)) \
)



# I would like to test this, but it keeps its own names, and requires you to access them through its own GetProcAddress function ...
#
#	# btw which of these do I need? and what ones did I miss?
#	# I saw it had a cmake ... cmake is great for typing `mkdir build && cd build && cmake ..`
#	# but cmake is absolute trash for trying to accomplish anything, like, oh, read the contents of the varibale that says what source files are being compiled...
#	# ... list taken from gl4es/src/CMakeLists.txt
#	GL4ES_SRCS = $(patsubst %, gl4es/src/%, \
#		gl/arbconverter.c gl/arbgenerator.c gl/arbhelper.c gl/arbparser.c gl/array.c gl/blit.c gl/blend.c gl/buffers.c gl/build_info.c gl/debug.c gl/decompress.c gl/depth.c gl/directstate.c gl/drawing.c gl/enable.c gl/envvars.c gl/eval.c gl/face.c gl/fog.c gl/fpe.c gl/fpe_cache.c gl/fpe_shader.c gl/framebuffers.c gl/gl_lookup.c gl/getter.c gl/gl4es.c gl/glstate.c gl/hint.c gl/init.c gl/light.c gl/line.c gl/list.c gl/listdraw.c gl/listrl.c gl/loader.c gl/logs.c gl/matrix.c gl/matvec.c gl/oldprogram.c gl/pixel.c gl/planes.c gl/pointsprite.c gl/preproc.c gl/program.c gl/queries.c gl/raster.c gl/render.c gl/samplers.c gl/shader.c gl/shaderconv.c gl/shader_hacks.c gl/stack.c gl/stencil.c gl/string_utils.c gl/stubs.c gl/texenv.c gl/texgen.c gl/texture.c gl/texture_compressed.c gl/texture_params.c gl/texture_read.c gl/texture_3d.c gl/uniform.c gl/vertexattrib.c gl/wrap/gl4eswraps.c gl/wrap/gles.c gl/wrap/glstub.c gl/math/matheval.c \
#		glx/hardext.c \
#	)
#	# Still not sure if this should be here for Makefile-native or just for Makefile(-wasm)
#	# Only -wasm needs it.
#	GL4ES_CFLAGS = -DNOX11=ON -DNOEGL=ON -DSTATICLIB=ON -I gl4es/include/
#
#	# add gl4es for GL 2 API compatability
#	DIST_SRCS+= $(GL4ES_SRCS)



############ clang, since emcc is wedging in tons of c++ crap, mangling symbol names, etc
#	# osx notice: use brew clang since builtin clang is a few versions behind and doesn't yet have wasm target:
#	#   `export PATH=/usr/local/opt/llvm/bin:$PATH`
#	CC=clang
#	#CC=clang++
#	O=.o	# .bc ?
#	DIST=lua-5.4.7-with-ffi.wasm	# .bca ?
#
#	# wasi-libc I built myself .. still missingruntimes,
#	#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot
#	#LDFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/sysroot
#	# so just using `brew install wasi-libc wasi-runtimes`
#	# and now <complex.h> doesn't work, so what went wrong
#	CFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot	# works
#	#LDFLAGS+= --sysroot /usr/local/Cellar/wasi-libc/25/share/wasi-sysroot	 # can't find -lc++ -lc++abi
#	#LDFLAGS+= --sysroot /usr/local/Cellar/wasi-runtimes/19.1.7/share/wasi-sysroot # can't find -lc -ldl etc ...
#	# adding LDFLAGS also causes link errors of looking for some c++ abi
#	# I suspect I shouldn't need to add either ... and that the wasi brew distribution is deficient?  or the brew configuration is messed up (since I'm export PATH this whole thing)
#
#	#CFLAGS+= --sysroot /Users/chris/Projects/other/wasi-libc/build # why ask me for an install dir if you're just going to install to ./sysroot ?
#	#CFLAGS+= --target=wasm32-wasi # works
#	#CFLAGS+= --target=wasm64 # 'string.h' file not found
#	#CFLAGS+= --target=wasm64-wasi # 'string.h' file not found
#	#CFLAGS+= --target=wasm64-unknown-wasi # 'string.h' file not found
#	CFLAGS+= --target=wasm32-unknown-wasi # works
#	LDFLAGS+= --target=wasm32-unknown-wasi
#	CFLAGS+= -O2
#
#	# for signals:
#	CFLAGS+= -D_WASI_EMULATED_SIGNAL
#	LDFLAGS+= -lwasi-emulated-signal
#
#	# for longjmp ...
#	CFLAGS+= -mllvm -wasm-enable-sjlj
#	# .. alternatively just compile ldo as C++ ( everything as C++?) and Lua will use throw instead:
#	#CFLAGS+= -x c++ #-std=c++11
#	#LDFLAGS+= -lc++ -lc++abi
#	#CFLAGS+= -fno-exceptions # but I want to use exception based lua errors
#	# but then I get link errors of `undefined symbol: __cxa_allocate_exception` so back to C...
#	#CFLAGS+= "-DLUA_API=extern \"C\""	# without this the luaffifb can't see lua functions, cuz it expects lua's functions to be in C and not C++
#
#	# tmpfile() is deprecated & L_tmpnam are missing on wasi-libc, so I made this flag to tell Lua build to get around that, and use the LUA_USE_POSIX tmpfile option:
#	CFLAGS+= -DLUA_TMPFILE_MISSING
#
#	# for clock() to work:
#	CFLAGS+= -D_WASI_EMULATED_PROCESS_CLOCKS
#	LDFLAGS+= -lwasi-emulated-process-clocks
#
#	# mmap:
#	CFLAGS+= -D_WASI_EMULATED_MMAN
#	LDFLAGS+= -lwasi-emulated-mman
#
#	# for luaffifb to tell the arch
#	CFLAGS+= -D__WASM__
#
#	LDFLAGS+= -ldl	# dlopen/dlsym
#
#	# "Despite claiming to be ISO C, iOS does not implement 'system'."
#	#CFLAGS+= -DLUA_USE_IOS
#	# but if you enable this it causes lots more compile/link errors to pop up ... so ...
#	CFLAGS+= -DLUA_MISSING_SYSTEM
#
#	LDFLAGS+= -Wl,--export-all	# where'd my symbols go?
#
#	# now for porting all those emscripten flags to clang flags (in emscripten's libexec/tools/building.py)
#	LDFLAGS+= -Wl,--growable-table -Wl,--max-memory=2147483648




############ emcc final:
	CC=emcc
	O=.o	# .bc?
	DIST=lua-5.4.7-with-ffi.js
	DIST_WASM=lua-5.4.7-with-ffi.wasm
	CFLAGS+= -g2		# keep all debug info
	LDFLAGS+= -g2		# keep all debug info
	#CFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
	#CFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
	##	-target=wasm64-unknown-emscripten
	#LDFLAGS+=- -no-debug -target=wasm64-unknown-emscripten -panic=trap -scheduler=none
	#LDFLAGS+= --profiling-funcs
	#LDFLAGS+= -Oz		# https://stackoverflow.com/a/67809004
	#LDFLAGS+= -O2		# https://github.com/emscripten-core/emscripten/issues/13806#issuecomment-811995664
	CFLAGS+= -O3		# needs O3 or it will error when trying to load the (complete empty but necessary to gain js access to dlopen/dlsym) side module wasm.
	LDFLAGS+= -O3
	#CFLAGS+= -O1
	#LDFLAGS+= -O1
	#CFLAGS+= -O0		# for some reason -O0 tells the js module wasm loader to load twice in async, and the 2nd load complains that the first load isn't finished.....smh
	#LDFLAGS+= -O0		#
	#CFLAGS+= -fwasm-exceptions	# gave me all sorts of "missing ___cxx_exception" problems
	#CFLAGS+= -x c++			# I only want this for Lua (right?)
	CFLAGS+= -fPIC
	LDFLAGS+= -s WASM=1
	#CFLAGS+= -s MEMORY64=1			# This will make you need to change every function arg from js -> emcc to wrap in BigInt, which is frustrating and absurd ...
	#LDFLAGS+= -s MEMORY64=1			# But hopefully enabling it will make it so underlying lua integers are not 32bit.
	#LDFLAGS+= -s WASM_BIGINT=1		# Google AI said this would fix the fact that HEAPU64 is missing.  emscripten changed something in the last year / when i went from osx to linux, where before i had 64-bit number support but not 64-bit memory support, and now i get both or neither..... oh in fact, this was always enabled-by-default, so is my linux emscripten really that old? 
	LDFLAGS+= -s MAXIMUM_MEMORY=2GB	# stupid internal emscripten bug, fixed with https://github.com/emscripten-core/emscripten/issues/20183
	LDFLAGS+= --no-entry
	CFLAGS+= -s MAIN_MODULE=1		# I need this to use dlopen/dlsym
	LDFLAGS+= -s MAIN_MODULE=1
	LDFLAGS+= -s MODULARIZE=1
	#CFLAGS+= -s STRICT=1			# setting STRICT makes emscripten (only with MAIN_MODULE?) request some mystery function __syscall_mprotect which isn't there, and telling it to ignore itself just gets more memory errors at runtime
	#LDFLAGS+= -s STRICT=1
	LDFLAGS+= -s EXPORT_ES6=1
	#LDFLAGS+= -s MALLOC=emmalloc
	LDFLAGS+= -s EXPORT_ALL=1
	LDFLAGS+= -s FILESYSTEM=1
	#LDFLAGS+= -s DEFAULT_TO_CXX=0		# if MAIN_MODULE/SIDE_MODULE isn't used then setting this to 0 will stop the _ underscore in front of C funciton names. fucking retarded.
	LDFLAGS+= -s ALLOW_TABLE_GROWTH=1	# need this for adding functions at runtime
	LDFLAGS+= -s ALLOW_MEMORY_GROWTH=1	# otherwise my apps die after a few seconds ... I suspect whenever memory grows, something gets invalidated and my next lua coroutine resume errors with "memory out of bounds"
	#LDFLAGS+= -s INITIAL_MEMORY=3900mb	# NOTICE necessary but i'm getting "not enough memory" errors with WASM so how tf do you make emscripten allocate ONLY THE MEMORY IT NEEDS, NOT TOO MUCH TO CRASH OUT, NOT TOO LITTLE TO CRASH OUT!!! FUCKING HELL I HATE EMSCRIPTEN
	#LDFLAGS+= -s INITIAL_HEAP=1gb		# can't do this because nonsense
	#LDFLAGS+= -s STACK_SIZE=5mb		# default is 64kb.  NOTICE same as INITIAL_MEMORY
	LDFLAGS+= -s MIN_WEBGL_VERSION=2
	LDFLAGS+= -s MAX_WEBGL_VERSION=2
	LDFLAGS+= -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=1	# idk, seems even tho the main draw of emscripten is gles<->webgl + sdl + c++ programming, seems the webgl version of things is pretty shitty
	CFLAGS+= -s USE_ZLIB=1
	LDFLAGS+= -s USE_ZLIB=1
	CFLAGS+= -s USE_LIBPNG=1
	LDFLAGS+= -s USE_LIBPNG=1
	CFLAGS+= -s USE_LIBJPEG=1
	LDFLAGS+= -s USE_LIBJPEG=1
	CFLAGS+= -s USE_SDL=3
	LDFLAGS+= -s USE_SDL=3
	LDFLAGS+= -s ENVIRONMENT="web"
	#LDFLAGS+= -s WASM_ASYNC_COMPILATION=0	# js init complains if I disable this
	#LDFLAGS+= -s ERROR_ON_UNDEFINED_SYMBOLS=0	# because emscripten wants some internal function __syscall_mprotect but it's internal to emscripten so it just errors for no fucking reason
	LDFLAGS+= -s 'EXPORTED_RUNTIME_METHODS=["FS","stringToNewUTF8","addFunction"]'
	LDFLAGS+= -s 'EXPORTED_FUNCTIONS=["_malloc","_free"]'		# is it absolutely random which functions emscripten chooses to export when you say EXPORT_ALL?  I have to still  manually specify these.  It will warn me that I don't since I already said EXPORT_ALL.  But EXPORT_ALL missed these.  And manually specifying them reminds emscripten to include them along with whatever is its idea of "all".

	# I want legacy ... and compat mode ... and it to not hinder / slow down stuff that doesn't use it ... too much to ask?
	# ANNNND of couse it's broke, because this is Emscripten.  It gives me "SyntaxError: Identifier '_glTexEnvfv' has already been declared (33532:2089)"
	# Time to go back to GL4ES and just patch in the names in Lua.
	# And I did, and it just spit out webgl drawarrays errors .. so now I'm back here figuring how how to circumvent an internal Emscripten link error ...
	#LDFLAGS+= -s LEGACY_GL_EMULATION=1
	#LDFLAGS+= -s GL_UNSAFE_OPTS=1
	#LDFLAGS+= -s GL_FFP_ONLY=1
	#LDFLAGS+= -s USE_GLFW=3		# this link says he uses it with glfw, maybe that'll fix emscripten's linking?   and nope.   https://github.com/emscripten-core/emscripten/issues/3242#issue-60616057

.PHONY: all
all: $(DIST)

.PHONY: clean
clean:
	-rm $(DIST_OBJS) $(DIST)


# compile rule for libffi, which needs some extra includes...
#
# ok there's libffi/src/wasm/ffitarget.h that comes with libffi
# and there's libffi/src/wasm/include/ffitarget.h that is generated from `emconfigure autoreconf -v -i && cd src/wasm32 && emconfigure ../../configure`
# and the dynamically generated one should be more legit right? after all, we have to dynamically generate the ffi.h because it's just not there to begin with
# and neither is good.
# the generated libffi/src/wasm/include/ffitarget.h has complex support but not extra fields, which makes the libffi code fail to compile.
# the builtin libffi/src/wasm/ffitarget.h has extra ffi_cif fields defined but no complex support, which makes the luaffifb code fail to link.
# looks like I will be generating it by hand ...
# 1) copy libffi/src/wasm/ffitarget.h libffi/src/wasm/include/ffitarget.h
# 2) add the line to the top: `#define FFI_TARGET_HAS_COMPLEX_TYPE`
# 3) now libffi/src/wasm/include/ has the good ffi.h and ffitarget.h
#
libffi/%.o: libffi/%.c
	$(CC) $(CFLAGS) $(LIBFFI_CFLAGS) -c -o $@ $^

# compile rule for luaffifb:
# make sure you have generated libffi's ffi.h for wasm already, as per README.md says
# make sure the include dir order matches libffi/ above, in order to use the same ffitarget.h
luaffifb/%.o: luaffifb/%.c
	$(CC) $(CFLAGS) $(LUAFFIFB_CFLAGS) -c -o $@ $^

#CFLAGS+=  -std=gnu99
lua/%.o: lua/%.c
	$(CC) $(CFLAGS) $(LUA_CFLAGS) -c -o $@ $^

cimgui/%.o: cimgui/%.cpp
	$(CC) $(CFLAGS) $(CIMGUI_CFLAGS) -c -o $@ $^

# nahhh not any more
#gl4es/%.o: gl4es/%.c
#	$(CC) $(CFLAGS) $(GL4ES_CFLAGS) -c -o $@ $^

# compile rule for all:
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

# final
# now comment out the module declaration because it uses 'var' which will screw up even if I wrap it all in a function with a `Module` arg
#sed 's/^var Module/\/\/var Module/' $(DIST) > temp && mv temp $(DIST)
# now assign HEAP ... which it does already when I don't use MAIN_MODULE/SIDE_MODULE, so why did it stop when I started using MAIN_MODULE/SIDE_MODULE ?
#sed 's/HEAP\([0-9a-zA-Z]*\) = /HEAP\1 = Module.HEAP\1 = /' $(DIST) > temp && mv temp $(DIST)
# seems FreeBSD sed is different from Linux sed
# now wrap it all in a module, because emscripten thinks using MAIN_MODULE/SIDE_MODULE prevents it from usinng modules / ES6 somehow (??? wtf)
#echo 'const defaultModule = (Module = {}) => new Promise((initResolve, initReject) => {' | cat - $(DIST) > temp && mv temp $(DIST)
#echo 'addOnPostRun(() => { initResolve(Module); }); }); export default defaultModule;' >> $(DIST)
# TODO ALSO comment out var Module = line OR ELSE IT BREAKS because JAVASCRIPT IS TRASH
# ALSO make sure in updateMemoryViews() to assign HEAP* to Module.HEAP* because EMSCRIPTEN IS TRASH TOO (it did this before, but stopped doing it when i switched to MAIN_MODULE/SIDE_MODULE, which was necessary to access dlopen/dlsym from js)
$(DIST): $(DIST_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^


.PHONY: distclean
distclean:
	-rm $(DIST)
	-rm $(DIST_WASM)

INSTALL_DIR=../../thenumbernine.github.io/js/
.PHONY: install
install: $(DIST)
	cp $(DIST) $(INSTALL_DIR)
	cp $(DIST_WASM) $(INSTALL_DIR)
	cp lua-interop/lua-interop.js $(INSTALL_DIR)
