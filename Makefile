.PHONY: compile enhance run stop

compile:
	./make/compile.sh

enhance:
	./make/enhance.sh

run: compile enhance
	./make/run.sh

stop:
	./make/stop.sh
