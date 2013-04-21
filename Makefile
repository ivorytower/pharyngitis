all: compile test build

compile:
	iced -c src

test: compile
	iced -c test
	mocha

build: compile
	./build
