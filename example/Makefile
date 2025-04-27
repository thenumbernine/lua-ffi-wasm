.PHONY: clean all run

all: main.js

clean:
	-rm *.o *.js *.wasm

CC=emcc
CXX=em++
#CC=clang
#CXX=clang++

main.js:
	$(CC) -fPIC -c side.c -s SIDE_MODULE=1 -o side.o
	$(CC) side.o -s SIDE_MODULE=1 -o side.wasm
	$(CC) -fPIC -c main.c -s MAIN_MODULE=1 -o main.o
	$(CXX) -fPIC -c main2.cpp -s MAIN_MODULE=1 -o main2.o
	$(CC) \
		-s MAIN_MODULE=1 \
		-s FILESYSTEM=1 \
		-s EXPORT_ALL=1 \
		-s 'EXPORTED_RUNTIME_METHODS=["FS"]' \
		side.wasm -o main.js main.o main2.o
	# WHY THE FUCK DOES MODULARIZE AND ES6 NOT WORK , BUT I CAN WRAP A MODULE HERE JUST FINE, WHAT THE FUCK IS WRONG WITH EMSCRIPTEN
	echo 'const init = (Module) => new Promise((initResolve, initReject) => {' | cat - main.js > temp && mv temp main.js
	echo 'addOnPostRun(() => { initResolve(Module); }); }); export {init};' >> main.js

run:
	open http://localhost:8000/index.html
	luajit -lhttp
