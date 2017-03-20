import unittest

from kuberoute.dns import Route53Client
from kuberoute.intent import GetDNSClient


class DNSClientTests(unittest.TestCase):
    def test_subclass_check(self):
        """GetDNSClient should throw an exception when instantiated with a
        class that does not implement NameService class.

        """
        with self.assertRaises(TypeError) as context:
            GetDNSClient(int, 1)

        # the following should never throw an exception
        GetDNSClient(
            Route53Client,
            aws_access_key_id='not a valid id',
            aws_secret_access_key='not a valid key',
            domain='not a valid domain'
        )
