all: compile test build

compile:
	coffee -c src

test: compile
	coffee -c test
	mocha

build: compile
	./build
