import unittest

import kuberoute.util


class UtilTests(unittest.TestCase):
    def test_dictionary_is_subset_empty(self):
        self.assertTrue(kuberoute.util.dictionary_is_subset({},{}))

    def test_dictionary_is_subset_same_keys(self):
        self.assertFalse(kuberoute.util.dictionary_is_subset({ 'a': 1 }, { 'a': 2}))

    def test_dictionary_is_subset_same_values(self):
        self.assertTrue(kuberoute.util.dictionary_is_subset({ 'a': 1 }, { 'a': 1 }))

    def test_dictionary_is_subset_true_subset(self):
        self.assertTrue(kuberoute.util.dictionary_is_subset(
            { 'a': 1 },
            { 'a': 1, 'b': 2 }
        ))

    def test_dictionary_is_subset_superset(self):
        self.assertFalse(kuberoute.util.dictionary_is_subset(
            { 'a': 1, 'b': 2 },
            { 'a': 1 },
        ))

    def test_check_condition(self):
        cond = kuberoute.util.check_condition(
            {
                'status': {
                    'conditions': [
                        {
                            'type': 'testcondition',
                            'status': 'False',
                            'reason': 'test reason',
                            'message': 'test message',
                        },
                    ]
                },
                'metadata': {
                    'name': 'test node',
                },
            },
            'testcondition',
        )
        self.assertTrue('message' in cond)

    def test_find_in_iter_not_in_list(self):
        self.assertTrue(kuberoute.util.find_in_iter(lambda x: x == 0, [1,2,3])
                        is None)

    def test_find_in_iter_null(self):
        self.assertTrue(kuberoute.util.find_in_iter(lambda x: True, []) is None)

    def test_find_in_iter_positive(self):
        self.assertTrue(kuberoute.util.find_in_iter(
            lambda x: x == 2,
            [1,2,3]
        ) == 2)
