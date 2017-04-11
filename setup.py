#!/usr/bin/env python3

from distutils.core import setup

setup(name='kuberoute',
      version='1.1',
      description='Update DNS records based on kubernetes services',
      author='Sebastian Jordan',
      author_email='jordan@schneevonmorgen.com',
      url='https://bitbucket.org/schneevonmorgen/kuberoute',
      packages=['kuberoute'],
      package_dir = {'': 'src'},
      scripts=['scripts/kuberoute'],
      install_requires = [
          'boto3',
          'effect',
          'jinja2',
          'pykube',
          'python-etcd',
          'route53',
          'tornado',
      ],
     )
