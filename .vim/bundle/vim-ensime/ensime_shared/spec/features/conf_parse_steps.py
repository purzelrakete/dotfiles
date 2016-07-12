import sys
from os import path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

from lettuce import *
from ensime_harness import TestVim
from ensime_shared.launcher import EnsimeLauncher

testDir = "ensime_shared/spec/features"
Failure = "Failure"

@step('The config (?P<conf_path>resources/\w+.conf)')
def existing_config(step, conf_path):
    world.config_path = path.abspath(testDir + "/" + conf_path)


@step('We load the config')
def load_config(step):
    c = None
    try:
        c = EnsimeLauncher.parse_config(world.config_path)
    except:
        c = Failure
    world.conf = c

@step('We extract the name (testing)')
def extract_testing(step, expected_name):
    name = world.conf['name']
    assert name == expected_name, \
        "Got %s" % name

@step("We extract the scala version (2.11.8)")
def extract_scala_version(step, version):
    v = world.conf['scala-version']
    assert v == version, \
        "Got %s" % v

@step("We can parse nested expressions")
def check_deep_nesting(step):
    name = world.conf["nest"][0]["name"]
    targets = world.conf["nest"][0]["targets"]
    assert (name == "nested" and targets == ["abc", "xyz"]) , \
        "Got %s" % name

@step("We receive a failure")
def check_failed_conf(step):
    assert world.conf == Failure , \
        "Should have failed"
