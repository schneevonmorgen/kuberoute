import kuberoute.intent
from effect import Effect
from effect.do import do
from effect.io import Display
from kuberoute.intent import (GetDNSClient, GetNodes, GetPods, GetServices,
                              NoOP, UpdateNameRecord)


def display(msg):
    return Effect(Display(msg))


@do
def print_members(coll):
    """Print the members of a collection to stdout"""
    for elem in coll:
        yield display(elem)


def get_services(api, namespace=None):
    return Effect(GetServices(api, namespace))


def get_pods(api, namespace=None):
    return Effect(GetPods(api, namespace))


def get_dns_client(klass, *args, **kwargs):
    """Get a client to amazon route53.

    Check kuberoute.dns.Route53Client for arguments and keyword
    arguments.

    """
    return Effect(GetDNSClient(klass, *args, **kwargs))


def update_name_record(client, name, values, ttl, record_type):
    return Effect(UpdateNameRecord(client, name, values, ttl, record_type))


def get_time():
    return Effect(kuberoute.intent.GetTime())


def get_nodes(api):
    return Effect(GetNodes(api))


def noop():
    return Effect(NoOP())
