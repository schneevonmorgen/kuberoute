"""Provides interface to effectfull computations through the effect API"""

import datetime

import pykube
from effect import ComposedDispatcher, TypeDispatcher, sync_performer
from kuberoute.dns import NameService


class NoOP(object):
    pass


@sync_performer
def noop_performer(dispatcher, intent):
    pass


class GetPods(object):
    def __init__(self, api, namespace):
        self.api = api
        self.namespace = namespace


@sync_performer
def get_pods_performer(_, intent):
    pods = pykube.Pod.objects(intent.api)
    if intent.namespace is None:
        return pods
    else:
        return pods.filter(namespace=intent.namespace)


class GetServices(object):
    def __init__(self, api, namespace):
        self.api = api
        self.namespace = namespace


@sync_performer
def get_services_performer(dispatcher, intent):
    services = pykube.Service.objects(intent.api)
    if intent.namespace is None:
        return services
    else:
        return services.filter(namespace=intent.namespace)


class GetDNSClient(object):
    def __init__(self, klass, *args, **kwargs):
        if not issubclass(klass, NameService):
            raise TypeError("Class {klass} is not a subclass of {superclass}".format(
                klass=klass,
                superclass=NameService
            ))
        self.klass = klass
        self.args = args
        self.kwargs = kwargs


@sync_performer
def get_dns_client_performer(dispatcher, intent):
    return intent.klass(*(intent.args), **(intent.kwargs))


class UpdateNameRecord(object):
    def __init__(self, client, name, values, ttl, record_type):
        self.client = client
        self.name = name
        self.values = values
        self.ttl = ttl
        self.record_type = record_type

@sync_performer
def update_name_record_performer(dispatcher, intent):
    return intent.client.create_or_update_record_set(
        intent.name,
        intent.values,
        intent.ttl,
        intent.record_type
    )


class WebserverWrite(object):
    def __init__(self, webserver, msg):
        self.webserver = webserver
        self.msg = msg


@sync_performer
def webserver_write_performer(dispatcher, intent):
    return intent.webserver.write(intent.msg)


class GetTime(object):
    def __init__(self):
        pass


@sync_performer
def get_time_performer(dispatcher, intent):
    return datetime.datetime.now()


class GetNodes(object):
    def __init__(self, api):
        self.api = api


@sync_performer
def get_nodes_performer(dispatcher, intent):
    return pykube.Node.objects(intent.api)


PYKUBE_DISPATCHER = TypeDispatcher({
    GetPods: get_pods_performer,
    GetServices: get_services_performer,
    GetNodes: get_nodes_performer,
    GetDNSClient: get_dns_client_performer,
    UpdateNameRecord: update_name_record_performer,
    WebserverWrite: webserver_write_performer,
    GetTime: get_time_performer,
    NoOP: noop_performer,
})
