# Funcions for symbols formatting

def completion_to_suggest(completion):
    """Convert from a completion to a suggestion."""
    res = {
        # We use just the method name as completion
        "word": completion["name"],
        # We show the whole method signature in the popup
        "abbr": formatted_completion_sig(completion),
        # We show method result/field type in a sepatate column
        "menu": formatted_completion_type(completion),
        # We allow duplicates, needed to show overloaded methods
        "dup": 1
        }
    return res

def formatted_completion_sig(completion):
    """Regenerate signature for methods. Return just the name otherwise"""
    f_result = completion["name"]
    if not completion["isCallable"]:
        # It's a raw type
        return f_result
    elif len(completion["typeInfo"]["paramSections"]) == 0:
        return f_result

    # It's a function type
    sections = completion["typeInfo"]["paramSections"]
    f_sections = [formatted_param_section(ps) for ps in sections]
    return u"{}{}".format(f_result, "".join(f_sections))

def formatted_completion_type(completion):
    """Use result type for methods. Return just the member type otherwise"""
    t_info = completion["typeInfo"]
    return t_info["name"] if not completion["isCallable"] else t_info["resultType"]["name"]

def formatted_param_section(section):
    """Format a parameters list. Supports the implicit list"""
    implicit = "implicit " if section["isImplicit"] else ""
    s_params = [(p[0], formatted_param_type(p[1])) for p in section["params"]]
    return "({}{})".format(implicit, concat_params(s_params))

def concat_params(params):
    """Return list of params from list of (pname, ptype)."""
    name_and_types = [": ".join(p) for p in params]
    return ", ".join(name_and_types)

def formatted_param_type(ptype):
    """Return the short name for a type. Special treatment for by-name and var args"""
    pt_name = ptype["name"]
    if pt_name.startswith("<byname>"):
        pt_name = pt_name.replace("<byname>[", "=> ")[:-1]
    elif pt_name.startswith("<repeated>"):
        pt_name = pt_name.replace("<repeated>[", "")[:-1] + "*"
    return pt_name
