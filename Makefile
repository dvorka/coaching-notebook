# Coaching Notebook: GWT + Google App Engine life-coaching web application
#
# Copyright (C) 2013-2026 Martin Dvorak <martin.dvorak@mindforger.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


###########################
# This project predates Maven/npm-style dependency management: all Java
# dependencies are vendored jars under war/WEB-INF/lib/, and the client is
# GWT (compiled Java -> JS; the compiled output is already committed under
# war/mind_forger/).
#
# These targets replace the dead Google Plugin for Eclipse (GPE) - see
# .project-legacy-gae-plugin for the GAE/GWT natures it used to declare, and
# make/enhance.sh for why its DataNucleus bytecode-enhancer build step had to
# be reimplemented by hand.
#
# Functinality: OUTLINER code has been purged from the sources of the original
# web MindForger project and renamed to Coaching Notebook. It can be re-added
# if needed.
#
# Quickstart:
#   make run     # compile + enhance + start the dev server on :8080
#   make stop    # stop it
#

.DEFAULT_GOAL := help

#
# VARIABLES
#

# no formal versioning yet - fall back to the current git commit
PROJECT_VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
# App Engine Java SDK 1.8.x install (DataNucleus enhancer + dev server live under here)
export GAE_SDK_HOME ?= /home/dvorka/p/openstack/kepler-64b/plugins/com.google.appengine.eclipse.sdkbundle_1.8.8/appengine-java-sdk-1.8.8
# dev server port
export PORT ?= 8080

#
# HELP
#

.PHONY: help
help: ## show this help
	@echo '  ___              _    _             _  _     _       _              _   '
	@echo ' / __|___  __ _ __| |_ (_)_ _  __ _  | \| |___| |_ ___| |__  ___  ___| |__'
	@echo '| (__/ _ \/ _` / _| '\'' \| | '\'' \/ _` | | .` / _ \  _/ -_) '\''_ \/ _ \/ _ \ / /'
	@echo ' \___\___/\__,_\__|_||_|_|_||_\__, | |_|\_\___/\__\___|_.__/\___/\___/_\_\'
	@echo '                              |___/  $(PROJECT_VERSION)'
	@echo ''
	@echo 'Coaching Notebook: GWT + Google App Engine life-coaching web app'
	@echo ''
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

#
# BUILD
#

.PHONY: compile
compile: ## compile src/ into war/WEB-INF/classes (javac, 1.7 bytecode target)
	./make/compile.sh

.PHONY: enhance
enhance: ## run the DataNucleus JDO bytecode enhancer over @PersistenceCapable classes
	./make/enhance.sh

#
# RUN
#

.PHONY: run
run: compile enhance ## compile + enhance + start the App Engine dev server (http://localhost:8080 by default, override with PORT=...)
	./make/run.sh

.PHONY: stop
stop: ## stop the running dev server
	./make/stop.sh
