"""Utility functions"""


def safeget(d, *keys, default_value=None):
    """Get values from nested dictionaries.

    Return None if a key is not available"""
    for key in keys:
        try:
            d = d[key]
        except KeyError:
            return default_value
    return d


def dictionary_is_subset(subset, superset):
    try:
        for key, value in subset.items():
            if superset[key] != value:
                return False
    except KeyError:
        return False
    return True


def check_condition(obj, condition_type):
    conditions = safeget(obj, 'status', 'conditions')
    for condition in conditions:
        if condition['type'] == condition_type:
            return condition
    return None


def render_template_string(msg, **replacements):
    return msg.replace("_TEMPLATE_START_", "{").replace("_TEMPLATE_END_", "}").format(
        **replacements
    )


def find_in_iter(pred, objects):
    for obj in objects:
        if pred(obj):
            return obj
    return None
