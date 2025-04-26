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
	# WHY THE FUCK DOES MODULARIZE AND ES6 NOT WORK , BUT I CAN WRAP A MODULE HERE JUST FINE, WHAT THE FUCK IS WRONG WITH EMSCRIPTEN
	echo 'const init = (Module) => new Promise((initResolve, initReject) => {' | cat - main.js > temp && mv temp main.js
	echo 'addOnPostRun(() => { initResolve(Module); }); }); export {init};' >> main.js

run:
	open http://localhost:8000/index.html
	luajit -lhttp
