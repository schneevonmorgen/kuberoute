from kuberoute.util import check_condition, safeget

def node_unschedulable(node):
    return safeget(node, 'spec', 'unschedulable') == True


def node_ready(node):
    cond = check_condition(node, 'Ready')
    if cond is not None:
        return cond['status'] == 'True'
    else:
        return False
