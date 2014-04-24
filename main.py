import os
import json
import re
import urllib
import webapp2
import jinja2
from  models import *

j = jinja2.Environment(
  loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))

class MainHandler(webapp2.RequestHandler):
  def get(self):
    self.response.out.write(j.get_template('templates/index.html').render({}))


class TableHandler(webapp2.RequestHandler):
  def get(self):
    place = Place.get_by_id(self.request.GET['place_id'])
    if place:
      tables = place.tables
      d = {}
      for t in tables:
        d[t.name] = t.to_dict()
      self.response.out.write(json.dumps(d))
    else:
      self.response.out.write(json.dumps({}))

  def post(self):
    p = self.request.POST
    d = json.loads(p.iterkeys().next())
    p = Place.get_or_insert(d['place']['id'], name=d['place']['name'])
    tables = []
    print d['tables']
    for k,v in d['tables'].items():
      t = Table()
      t.name = v['name']
      t.row = v['row']
      t.column = v['column']
      t.width = v['width']
      t.height = v['height']
      t.qty = v['qty']
      tables.append(t)
    p.tables = tables
    p.put()

app = webapp2.WSGIApplication([('/', MainHandler),
                               ('/table', TableHandler)
                              ],
                              debug=True)
