PYTHON := python2
VENV := .venv

activate := $(VENV)/bin/activate
requirements := requirements.txt test-requirements.txt
deps := $(VENV)/deps-updated

test: $(deps)
	@echo "Running ensime-vim lettuce tests"
	. $(activate) && lettuce ensime_shared/spec/features

$(activate):
	virtualenv -p $(PYTHON) $(VENV)

$(deps): $(activate) $(requirements)
	$(VENV)/bin/pip install --upgrade --requirement requirements.txt
	$(VENV)/bin/pip install --upgrade --requirement test-requirements.txt
	touch $(deps)

lint: $(deps)
	. $(activate) && flake8 --max-complexity=10 *.py **/*.py

format: $(deps)
	. $(activate) && autopep8 -aaa --in-place *.py **/*.py

clean:
	@echo Cleaning build artifacts, including the virtualenv...
	-rm -rf $(VENV)
	-find . -name '*.pyc' -exec rm -f {} +
	-find . -name '*.pyo' -exec rm -f {} +

.PHONY: test lint format clean
