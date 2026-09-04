.PHONY: compile enhance run

compile:
	./make/compile.sh

enhance:
	./make/enhance.sh

run: compile enhance
	./make/run.sh
