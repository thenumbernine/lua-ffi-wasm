.PHONY: clean all run

all: main.js

clean:
	-rm *.o *.js *.wasm

main.js:
	emcc -fPIC -c side.c -s SIDE_MODULE=1 -o side.o
	emcc side.o -s SIDE_MODULE=1 -o side.wasm
	emcc -fPIC -c main.c -s MAIN_MODULE=1 -o main.o
	emcc \
		--no-entry \
		-s MAIN_MODULE=1 \
		-s FILESYSTEM=1 \
		-s EXPORT_ALL=1 \
		-s 'EXPORTED_RUNTIME_METHODS=["FS"]' \
		side.wasm -o main.js main.o

run:
	open http://localhost:8000/index.html
	luajit -lhttp
