.PHONY: clean all run

all: main.js

clean:
	-rm *.o *.js *.wasm

main.js:
	# SIDE_MODULE=1 needed in -c stage
	emcc -c side.c \
		-s SIDE_MODULE=1 \
		-o side.o
#		-s LINKABLE=1
	emcc side.o -s SIDE_MODULE=1 -o side.wasm
	emcc main.c \
		-s MAIN_MODULE=1 \
		-s EXPORT_ALL=1 \
		-s FILESYSTEM=1 \
		-s 'EXPORTED_RUNTIME_METHODS=["FS","wasmExports"]' \
		side.wasm -o main.js
# adding lots of garbage:
#		-s EXPORT_ALL=1
#		-s LINKABLE=1
	# dlsym DOES NOT WORK with 'MODULARIZE' or 'EXPORT_ES6'
#		-s MODULARIZE=1
#		-s EXPORT_ES6=1
	echo 'const init = async(Module={})=>{' | cat - main.js > temp && mv temp main.js
	echo 'return Module;}; export{init};' >> main.js
	# NEXT CHALLENGE - exporting 'side' function to js, and exporting 'dlsym' to js
run:
	open http://localhost:8000/index.html
	luajit -lhttp
