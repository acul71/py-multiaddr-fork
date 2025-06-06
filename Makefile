.PHONY: clean-pyc clean-build docs clean
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"
	@echo "lint - check style with ruff"
	@echo "test - run tests quickly with the default Python"
	@echo "test-all - run tests on every Python version with tox"
	@echo "coverage - check code coverage quickly with the default Python"
	@echo "docs - generate Sphinx HTML documentation, including API docs"
	@echo "release - package and upload a release"
	@echo "dist - package"
	@echo "install - install the package to the active Python's site-packages"

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

setup:
	pip install -r requirements_dev.txt

lint:
	python -m ruff check --fix

fix:
	python -m ruff check --fix

typecheck:
	pre-commit run pyright-pretty --all-files

test:
	python -m pytest tests

test-all:
	python3.11 -m pytest tests
	python3.13 -m pytest tests

coverage:
	coverage run --source multiaddr setup.py test
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs:
	rm -f docs/multiaddr.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ multiaddr
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

readme.html: README.rst
	rst2html.py README.rst > readme.html

.PHONY: authors
authors:
	git shortlog --numbered --summary --email | cut -f 2 > AUTHORS

dist: clean
	python setup.py sdist
	python setup.py bdist_wheel

install: clean
	python setup.py install

bump:
	bumpversion --tag-name "{new_version}" patch

deploy-prep: clean authors readme.html docs dist
	@echo "Did you remember to bump the version?"
	@echo "If not, run 'bumpversion {patch, minor, major}' and run this target again"
	@echo "Don't forget to update HISTORY.rst"
