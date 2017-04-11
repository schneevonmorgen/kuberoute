"""This module provides the means to conntect to a kubernetes api server"""
import base64

import effect
import jinja2
import pykube


class FromServiceAccount(object):
    def __init__(self):
        pass


@effect.sync_performer
def from_service_account_performer(*_):
    return pykube.HTTPClient(pykube.config.KubeConfig.from_service_account())


class ConfigFromServer(object):
    def __init__(self, url, verify, certificate_authority):
        self.url = url
        self.verify = verify
        self.certificate_authority = certificate_authority


@effect.sync_performer
def config_from_server_performer(_, intent):
    template = jinja2.Environment().from_string(KUBECONFIG_TEMPLATE)
    kubeconfig = template.render(dict(
        kubernetes_api_server=intent.url,
        kubernetes_not_verify=not intent.verify,
        kubernetes_certificate_authority=intent.certificate_authority
    ))
    return pykube.HTTPClient(
        pykube.KubeConfig.from_file(
            pykube.config.BytesOrFile(
                data=base64.b64encode(kubeconfig.encode())
            ).filename()
        )
    )


class FromKubeConfig(object):
    def __init__(self, filename):
        self.filename = filename


@effect.sync_performer
def from_kube_config_performer(_, intent):
    return pykube.HTTPClient(pykube.KubeConfig.from_file(intent.filename))


AUTH_DISPATCHER = effect.TypeDispatcher({
    ConfigFromServer: config_from_server_performer,
    FromServiceAccount: from_service_account_performer,
    FromKubeConfig: from_kube_config_performer
})


def from_service_account():
    return effect.Effect(FromServiceAccount())


def from_url(url, certificate_authority=None, verify=True):
    return effect.Effect(
        ConfigFromServer(url, verify, certificate_authority))


def from_kubeconfig(filename):
    return effect.Effect(
        FromKubeConfig(filename)
    )


KUBECONFIG_TEMPLATE = """
apiVersion: v1
clusters:
- cluster:
    server: {{ kubernetes_api_server }}
    insecure-skip-tls-verify: {{ kubernetes_not_verify }}
    {% if kubernetes_certificate_authority %}certificate-authority: {{ kubernetes_certificate_authority }}{% endif %}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: ""
  name: default
current-context: default
kind: Config
preferences: {}
"""
