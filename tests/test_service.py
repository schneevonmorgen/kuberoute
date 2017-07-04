import unittest

from kuberoute.dns import Record
from kuberoute.service import (get_host_ip, get_name_record_updates,
                               get_pods_for_service, has_label,
                               is_node_port_service, is_pod_ready,
                               is_pod_running, service_selector)
from kuberoute.util import safeget


def add_if_missing(d, path, value):
    for p in path[:-1]:
        try:
            d = d[p]
        except KeyError:
            d[p] = dict()
            d = d[p]
    try:
        return d[path[-1]]
    except KeyError:
        d[path[-1]] = value
        return value


class MockAPIObject(object):
    def __init__(self, specs):
        self.obj = specs


class MockPodObject(MockAPIObject):
    def __init__(self, specs):
        super().__init__(specs)
        if 'status' not in self.obj:
            self.obj['status'] = {}
        self.obj['status']['phase'] = safeget(specs, 'status', 'phase', default_value='Running')
        try:
            conds = self.obj['status']['conditions']
        except KeyError:
            self.obj['status']['conditions'] = []
            conds = self.obj['status']['conditions']
        if len([ d for d in conds if 'type' in d and d['type'] == 'Ready']) == 0:
            conds += [{
                'type': 'Ready',
                'status': 'True',
            }]


TESTSERVICE=MockAPIObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testservice',
        'namespace': 'default',
        'labels': {
            'label1': 'value1',
            'kuberoute_domain': 'domain',
            'kuberoute_name': 'name',
            'kuberoute_failover': 'failover.url',
        },
    },
    'spec': {
        'selector': {
            'selectorlabel': 'selectorvalue'
        },
        'type': 'NodePort',
    },
})

TESTSERVICE_REPLACE=MockAPIObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testservice',
        'namespace': 'default',
        'labels': {
            'label1': 'value1',
            'kuberoute_domain': 'domain',
            'kuberoute_name': '_TEMPLATE_START_name_replace_TEMPLATE_END_',
            'kuberoute_failover': 'failover.url',
        },
    },
    'spec': {
        'selector': {
            'selectorlabel': 'selectorvalue'
        },
        'type': 'NodePort',
    },
})

TESTPOD_IN_SERVICE=MockPodObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testpod',
        'namespace': 'default',
        'labels': {
            'selectorlabel': 'selectorvalue',
            'slabel2': 'svalue2',
        }
    },
    'spec': {
        'containers': [
            {
                'image': 'testimage',
                'name': 'testapp'
            }
        ]
    },
    'status': {
        'hostIP': '1.0.0.0',
    }
})

TESTPOD_TERMINATING=MockPodObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testpod',
        'namespace': 'default',
        'labels': {
            'selectorlabel': 'selectorvalue',
            'slabel2': 'svalue2',
        }
    },
    'spec': {
        'containers': [
            {
                'image': 'testimage',
                'name': 'testapp'
            }
        ]
    },
    'status': {
        'hostIP': '1.0.0.0',
        'phase': 'Terminating',
    }
})

TESTPOD_NOT_READY=MockPodObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testpod',
        'namespace': 'default',
        'labels': {
            'selectorlabel': 'selectorvalue',
            'slabel2': 'svalue2',
        }
    },
    'spec': {
        'containers': [
            {
                'image': 'testimage',
                'name': 'testapp'
            }
        ]
    },
    'status': {
        'hostIP': '1.0.0.0',
        'conditions': [
            {
                'type': 'Ready',
                'status': 'False',
            }
        ]
    }
})

TESTPOD_NOT_IN_SERVICE=MockPodObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testpod2',
        'namespace': 'default',
        'labels': {
            'slabel2': 'svalue2',
        }
    },
    'spec': {
        'containers': [
            {
                'image': 'testimage',
                'name': 'testapp'
            }
        ]
    },
    'status': {
        'hostIP': '1.0.0.1'
    }
})

TESTPOD_IN_OTHER_NAMESPACE=MockPodObject({
    'apiVersion': 'v1',
    'metadata': {
        'name': 'testpod',
        'namespace': 'not-default',
        'labels': {
            'selectorlabel': 'selectorvalue',
            'slabel2': 'svalue2',
        }
    },
    'spec': {
        'containers': [
            {
                'image': 'testimage',
                'name': 'testapp'
            }
        ]
    },
    'status': {
        'hostIP': '1.0.0.0'
    }
})

TEST_NODE_1={
    'status': {
        'addresses': [
            {
                'address': '1.0.0.0',
                'type': 'InternalIP',
            },
        ],
    },
}

TEST_NODE_2={
    'spec': {
        'unschedulable': True,
    },
    'status': {
        'addresses': [
            {
                'address': '1.0.0.1',
                'type': 'InternalIP',
            },
        ],
    },
}

TEST_NODES = [ TEST_NODE_1, TEST_NODE_2 ]


class ServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = TESTSERVICE
        self.pod = TESTPOD_IN_SERVICE
        self.pod2 = TESTPOD_NOT_IN_SERVICE
        self.pod3 = TESTPOD_IN_OTHER_NAMESPACE
        self.pods = [ self.pod, self.pod2, self.pod3 ]
        self.nodes = TEST_NODES

    def test_has_label(self):
        self.assertTrue(has_label('label1', self.service))

    def test_service_selector(self):
        selector = service_selector(self.service)
        self.assertEqual(1, len(selector.keys()))
        self.assertTrue('selectorlabel' in selector.keys())
        self.assertTrue('selectorvalue' in selector.values())

    def test_get_pods_for_service(self):
        filtered_pods = get_pods_for_service(self.service,
                                             [self.pod, self.pod2])
        self.assertTrue(
            self.pod in filtered_pods,
            msg='self.pod should be in service'
        )
        self.assertFalse(
            self.pod2 in filtered_pods,
            msg='self.pod2 should not be connected to the service'
        )

    def test_get_pods_for_service_empty_list(self):
        filtered_pods = get_pods_for_service(self.service, [])
        self.assertEqual(len(filtered_pods), 0)


    def test_get_pods_for_service_other_namespace(self):
        filtered_pods = get_pods_for_service(self.service, self.pods)
        self.assertEqual(len(filtered_pods), 1)


    def test_get_host_ip(self):
        self.assertEqual(get_host_ip(self.pod), '1.0.0.0')

    def test_is_node_port_service(self):
        self.assertTrue(is_node_port_service(self.service))
        self.assertFalse(is_node_port_service(self.pod))

    def test_get_name_record_updates_empty(self):
        self.assertEqual(
            {},
            get_name_record_updates(
                [],
                [],
                [],
                'kuberoute_domain',
                'kuberoute_name',
                'kuberoute_failover',
                'kuberoute_quota'
            )
        )

    def test_get_name_record_updates(self):
        self.assertEqual(
            {
                'domain': [Record(
                    name='name',
                    domain='domain',
                    addresses=['1.0.0.0'],
                    failover='failover.url'
                )],
            },
            get_name_record_updates(
                [self.service],
                [self.pod, self.pod2],
                self.nodes,
                'kuberoute_domain',
                'kuberoute_name',
                'kuberoute_failover',
                'kuberoute_quota',
            )
        )

    def test_get_name_record_replacement(self):
        self.assertEqual(
            {
                'domain': [Record(
                    name='name',
                    domain='domain',
                    addresses=['1.0.0.0'],
                    failover='failover.url'
                )],
            },
            get_name_record_updates(
                [TESTSERVICE_REPLACE],
                [self.pod, self.pod2],
                self.nodes,
                'kuberoute_domain',
                'kuberoute_name',
                'kuberoute_failover',
                'kuberoute_quota',
                replacements={ 'name_replace': 'name'}
            )
        )

    def test_is_pod_running_false(self):
        self.assertFalse(is_pod_running(TESTPOD_TERMINATING))

    def test_is_pod_running_true(self):
        self.assertTrue(is_pod_running(TESTPOD_IN_SERVICE))

    def test_is_pod_ready_false(self):
        self.assertFalse(is_pod_ready(TESTPOD_NOT_READY))

    def test_is_pod_ready_true(self):
        self.assertTrue(is_pod_ready(TESTPOD_IN_SERVICE))

    def test_add_if_missing(self):
        d = {}
        add_if_missing(d,['a'],1)
        self.assertTrue('a' in d)

    def test_add_if_missing_nested(self):
        d = {}
        add_if_missing(d,['a','b'],1)
        self.assertTrue('b' in d['a'])
