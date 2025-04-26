.PHONY: clean all run

all: main.js

clean:
	-rm *.o *.js *.wasm

main.js:
	emcc -c side.c \
		-s SIDE_MODULE=1 \
		-o side.o
	emcc side.o -s SIDE_MODULE=1 -o side.wasm
	emcc main.c \
		-s INVOKE_RUN=0 \
		-s MAIN_MODULE=1 \
		-s FILESYSTEM=1 \
		-s EXPORT_ALL=1 \
		-s 'EXPORTED_RUNTIME_METHODS=["FS","wasmExports","dlopenInternal","callMain"]' \
		side.wasm -o main.js

run:
	open http://localhost:8000/index.html
	luajit -lhttp
