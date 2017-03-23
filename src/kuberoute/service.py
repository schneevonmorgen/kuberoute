"""This module contains procedure and functions for handling
services"""

from kuberoute.dns import Record
from kuberoute.util import check_condition, dictionary_is_subset, safeget


def has_label(labelname, service):
    """Returns true if the supplied service resource has label called
    *labelname*, else false"""

    labels = safeget(service.obj, 'metadata', 'labels')
    if labels is None:
        return False
    return labelname in labels.keys()


def service_selector(service):
    """Returns the kubernetes selector for a service.

    The selector defines which pods are expected to implement the
    service.

    """
    return safeget(service.obj, 'spec', 'selector')


def get_pods_for_service(service, pods):
    selector = service_selector(service)

    def filter_pod(pod):
        pod_labels = safeget(pod.obj, 'metadata', 'labels')
        if pod_labels is None:
            return False
        return (
            dictionary_is_subset(selector, pod_labels) and
            (
                safeget(pod.obj, 'metadata', 'namespace') ==
                safeget(service.obj, 'metadata', 'namespace')
            )
        )
    
    return list(filter(
        filter_pod,
        pods
    ))


def get_host_ip(pod):
    return safeget(pod.obj, 'status', 'hostIP')


def is_node_port_service(service):
    return (safeget(service.obj, 'spec', 'type')) == 'NodePort'


def is_pod_running(pod):
    return (safeget(pod.obj, 'status', 'phase') == 'Running')


def is_pod_ready(pod):
    condition = check_condition(pod.obj, 'Ready')
    return condition['status'] == 'True'


def get_name_record_updates(
        services, pods, domain_label, name_label, failover_label, quota_label):
    """Generate name records from a list of services and a list of pods

    services: a list of all available services as returned by pykube
    pods: a list of all available pods as returned by pykube
    domain_label: a string, all services with this label name are queried.  
                  The value of this label defines, on which domain the 
                  service will be published, e.g. schneevonmorgen.com.
    name_label: a string, all services with this label name are queried.  
                The value of this label defines under which name the 
                service will be published.
    failover_label: a string, to get a failover address in case the service 
                    is unavailable
    quota_label: a string, to get the required quota for the service to be 
                 considered "live"

    Returns a dictionary where the keys are domains and the values are
    lists of kuberoute.dns.Record.
    """
    records = {}
    for service in services:
        if not (is_node_port_service(service) and
                has_label(domain_label, service) and
                has_label(name_label, service)
               ):
            continue
        domain = safeget(service.obj, 'metadata', 'labels', domain_label)
        name = safeget(service.obj, 'metadata', 'labels', name_label)
        if domain is None or name is None:
            continue
        filtered_pods = filter(
            lambda obj: is_pod_running(obj) and is_pod_ready(obj),
            get_pods_for_service(service, pods)
        )
        ip_addresses = list(map(get_host_ip, filtered_pods))
        failover = safeget(service.obj, 'metadata', 'labels', failover_label)
        try:
            quota = int(safeget(service.obj, 'metadata', 'labels', quota_label))
        except TypeError:
            quota = 0
        if records.get(domain, None) is None:
            records[domain] = []
        records[domain].append(
            Record(
                name, domain, ip_addresses, failover=failover, quota=quota
            )
        )
    return records


def record_quota_fullfilled(record, nodes):
    if record.quota is None:
        return True
    return 100 * len(record.addresses) / len(nodes) >= record.quota
