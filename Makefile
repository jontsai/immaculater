# See README.md.

.PHONY: help
help:
	@echo "See README.md but maybe... make venv; source venv/bin/activate; make test"

.PHONY: localmigrate
localmigrate: venv/requirements-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	python manage.py migrate

.PHONY: localsuperuser
localsuperuser: venv/requirements-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	python manage.py createsuperuser

venv:
	@echo "Install virtualenv system-wide via 'pip3 install virtualenv' if the following fails:"
	virtualenv -p python3 venv
	@echo "Now run the following:"
	@echo "source venv/bin/activate"

.PHONY: pipinstall
pipinstall: venv/requirements-installed-by-makefile venv/requirements-test-installed-by-makefile

venv/requirements-installed-by-makefile: requirements.txt | venv
	@./ensure_virtualenv.sh || exit 1
	pip3 install -r $<
	touch $@

venv/requirements-test-installed-by-makefile: requirements-test.txt | venv
	@./ensure_virtualenv.sh || exit 1
	pip3 install -r $<
	touch $@

venv/bin/pipdeptree: venv
	@./ensure_virtualenv.sh || exit 1
	pip3 install pipdeptree

.PHONY: pipdeptree
pipdeptree: venv/bin/pipdeptree venv/requirements-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	./venv/bin/pipdeptree

.PHONY: local
local: venv/requirements-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	DJANGO_DEBUG=True python manage.py runserver 5000

.PHONY: sh
sh: venv/requirements-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	cd pyatdllib && make sh

.PHONY: djsh
djsh: venv/requirements-installed-by-makefile venv/requirements-test-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	cd pyatdllib && make sh

.PHONY: clean
clean: # you need protoc (Google's protobuf compiler) to regenerate *_pb2.py
	rm -f *.pyc **/*.pyc
	cd pyatdllib && make clean

# TODO: 'make clean' prints out 'To be perfectly clean, see 'immaculater reset_database'.'
.PHONY: distclean
distclean:
	make clean
	rm -f db.sqlite3
	rm -fr venv
	rm -f pyatdllib/core/pyatdl_pb2.py # should already be deleted but just in case
	@echo "Print deactivate your virtualenv. Exit the shell if you do not know how."

# test and run the flake8 linter (unless ARGS is --nolint):
.PHONY: test
test: venv/requirements-installed-by-makefile venv/requirements-test-installed-by-makefile
	@./ensure_virtualenv.sh || exit 1
	cd pyatdllib && make test
	python ./run_django_tests.py $(ARGS)
	@echo ""
	@echo "Tests and linters passed".

.PHONY: cov
cov: venv
	cd pyatdllib && make cov

.PHONY: pychecker
pychecker: venv
	cd pyatdllib && make pychecker

.PHONY: pylint
pylint: venv
	cd pyatdllib && make pylint

# counts lines of code
.PHONY: dilbert
dilbert: 
	wc -l `find todo immaculater pyatdllib -name '.git' -prune -o -name '*_pb2.py' -prune -o -type f -name '*.py' -print` pyatdllib/core/pyatdl.proto todo/templates/*.html immaculater/static/immaculater/*.js

.DEFAULT_GOAL := help
