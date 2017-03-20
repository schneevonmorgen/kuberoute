from kuberoute.node import node_ready, node_unschedulable
from kuberoute.util import safeget


def report_from_nodes(nodes):
    return dict([
        (safeget(node, "metadata", "name"), {
            "schedulable": not node_unschedulable(node),
            "ready": node_ready(node),
        })
        for node in nodes
    ])
