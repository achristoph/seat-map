from google.appengine.ext import ndb

class Table(ndb.Model):
  name = ndb.StringProperty()
  qty = ndb.IntegerProperty()
  row = ndb.IntegerProperty()
  column = ndb.IntegerProperty()
  width = ndb.IntegerProperty()
  height = ndb.IntegerProperty()

class Place(ndb.Model):
  name = ndb.StringProperty(default=None)
  tables = ndb.StructuredProperty(Table, repeated=True)

  @property
  def inspections(self):
    return Table.query(Table.place == self.key)

  def __unicode__(self):
    return "%s" % self.name
