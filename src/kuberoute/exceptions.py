class ApiServerError(Exception):
    def __init__(self, msg, inner):
        self.inner = inner


class DNSError(Exception):
    pass
