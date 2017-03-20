import tornado.web
from effect import Effect
from kuberoute.intent import WebserverWrite


class RequestHandler(tornado.web.RequestHandler):
        
    def write_msg(self, msg):
        return Effect(WebserverWrite(self, msg))
