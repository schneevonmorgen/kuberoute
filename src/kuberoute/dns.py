import json
import logging
import os
import sys
from abc import ABCMeta, abstractmethod

import etcd
import route53


class Record(object):
    def __init__(self, name, domain, addresses, failover, record_type='A', quota=0):
        self.name = name
        self.addresses = list(set(addresses))
        self.quota = quota
        self.record_type = record_type
        self.failover = failover
        self.domain = domain

    def __eq__(self, other):
        return (
            self.name == other.name and
            self.addresses == other.addresses and
            self.quota == other.quota and
            self.record_type == other.record_type and
            self.failover == other.failover and
            self.domain == other.domain
        )

    def __str__(self):
        return "Record: (domain=%(domain)s,name=%(name)s,addresses=%(addresses)s,quota=%(quota)s,record_type=%(record_type)s,failover=%(failover)s)" % dict(
            domain=self.domain,
            name=self.name,
            addresses=self.addresses,
            quota=self.quota,
            record_type=self.record_type,
            failover=self.failover
        )


class NameService(metaclass=ABCMeta):
    @abstractmethod
    def create_or_update_record_set(self, name, values, ttl, record_type):
        pass


class Route53Client(NameService):
    def __init__(self, domain, aws_access_key_id, aws_secret_access_key):
        self.aws_access_key_id = aws_access_key_id
        self.aws_secret_access_key = aws_secret_access_key
        self.zone = self._get_zone_by_domain(domain)
        self.domain = domain

    def _get_connection(self):
        if not hasattr(self, 'conn'):
            self.conn = route53.connect(
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
            )
        return self.conn

    def _get_zone_by_domain(self, domain):
        conn = self._get_connection()
        for zone in conn.list_hosted_zones(page_chunks=1000):
            if zone.name == '%s.' % domain:
                return zone

    def _get_record_set(self, hostname):
        for record_set in self.zone.record_sets:
            if record_set.name == '%s.' % hostname:
                return record_set

    def create_or_update_record_set(self, name, values, ttl, record_type):
        hostname = "%s.%s" % (name, self.domain)
        record_set = self._get_record_set(hostname)

        will_delete = (
            values is None or
            len(values) is 0
        )

        if record_set and not will_delete:
            if sorted(record_set.records) != sorted(values) or \
                    record_set.ttl != ttl:
                record_set.records = values
                record_set.ttl = ttl
                change_info = record_set.save()
        elif record_set and will_delete:
            record_set.delete()
        elif record_set is None and will_delete:
            pass
        else:
            fn_map = {
                'A': self.zone.create_a_record,
                'CNAME': self.zone.create_cname_record,
            }
            fn = fn_map.get(record_type.upper(), None)
            if fn is None:
                raise NotImplementedError(
                    "Creating %s records is not implemented" % record_type)
            record_set, change_info = fn(name=hostname, values=values, ttl=ttl)
            logging.debug("Entry %s: Created" % hostname)
        return record_set


class SkyDNSClient(NameService):
    def __init__(self, domain,
                 host='127.0.0.1',
                 protocol='https',
                 port='2379'):
        self.etcd_host = host
        self.etcd_protocol = protocol
        self.etcd_port = port
        self.domain = domain
        self.client = etcd.Client(
            host=self.etcd_host,
            port=int(self.etcd_port),
            protocol=self.etcd_protocol
        )

    def create_or_update_record_set(self, name, values, ttl, record_type):
        full_name = '{name}.{domain}'.format(
            name=name,
            domain=self.domain
        )
        path = '/skydns/' + '/'.join(list(reversed(full_name.split('.'))))
        for index in range(1,len(values) + 1):
            entry = {
                'host': values[index-1]
            }
            self.client.write(
                path + '/x{i}'.format(i=index),
                json.dumps(entry))
        return {
            'name': full_name,
            'addresses': values
        }


class FakeDNSClient(NameService):
    def __init__(self):
        pass

    def create_or_update_record_set(self, *args):
        print("Update dns record", args)
