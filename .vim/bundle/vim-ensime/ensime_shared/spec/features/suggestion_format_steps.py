from lettuce import *
from ensime_shared.symbol_format import *
from unittest import TestCase

tc = TestCase("__init__")

@step('Parameter type with name (.+)')
def given_parameter_type(step, tname):
    world.ptype = {"name": tname}

@step('We format the type')
def format_parameter_type(step):
    world.formatted = formatted_param_type(world.ptype)

@step('We get the format (.+)')
def get_formatted(step, expected_format):
    tc.assertEqual(world.formatted, expected_format)

@step('A list of type parameters:')
def given_a_list_of_type_parameters(step):
    world.tparams = [tp['tparam'] for tp in step.hashes]

@step('A list of parameters:')
def given_a_list_of_parameters(step):
    world.params = [(p['pname'], p['ptype']) for p in step.hashes]

@step('We concat the parameters')
def concat_parameters(step):
    world.formatted = concat_params(world.params)

@step('We get the empty string')
def get_formatted(step):
    tc.assertEqual(world.formatted, "")

@step('The section is (.*)implicit')
def section_implicit(step, implicit):
    world.implicit = implicit != 'not '

@step('We format the section')
def format_section(step):
    params = [(p[0], {"name": p[1]}) for p in world.params]
    section = {
        "params": params,
        "isImplicit": world.implicit
    }
    world.formatted = formatted_param_section(section)

@step('Completion with isCallable (.+)')
def given_completion_callable(step, is_callable):
    world.is_callable = is_callable

@step('TypeInfo with type (.+)')
def typeinfo_with_type(step, ctype):
    world.ctype = ctype

@step('TypeInfo with resultType (.+)')
def typeinfo_with_return_type(step, crtype):
    world.crtype = crtype

@step('We format the completion type')
def format_completion_type(step):
    world.completion = {
        "isCallable": world.is_callable == 'True',
        "typeInfo": {
            "name": world.ctype,
            "resultType": {"name": world.crtype}
        }
    }
    world.formatted = formatted_completion_type(world.completion)

@step('Name is (.+)')
def name_is(step, name):
    world.name = name

def hash_to_section(h):
    return {
        "params": [(h["pname"], {"name": h["ptype"]})],
        "isImplicit": h["implicit"] == "True"
    }

@step('Sections:')
def sections(step):
    world.sections = map(hash_to_section, step.hashes)

@step('We format the signature')
def format_sig(step):
    completion = {
        "name": world.name,
        "isCallable": world.is_callable == 'True',
        "typeInfo": {"paramSections": world.sections}
    }
    world.formatted = formatted_completion_sig(completion)

def hash_to_completion(h):
    completion = {
        "name": h["name"],
        "isCallable": h["is_callable"] == 'True',
        "typeInfo": {"name": h["ctype"]}
    }

    if h["crtype"]:
        completion["typeInfo"]["resultType"] = {"name": h["crtype"]}

    completion["typeInfo"]["paramSections"] = [hash_to_section(h)] if h["pname"] else []
    return completion

@step('We have the following completions:')
def we_have_completions(step):
    world.completions = map(hash_to_completion, step.hashes)

@step('We convert completions to suggestions')
def convert_completions_to_suggestions(step):
    world.suggestions = map(completion_to_suggest, world.completions)

@step('We get the following suggestions')
def we_get_suggestions(step):
    expected_suggestions = step.hashes
    for i in xrange(len(expected_suggestions)):
        expected_suggestions[i]["dup"] = 1
    tc.assertEqual(world.suggestions, expected_suggestions)
