services.factory 'Tables', () ->
  tables = {}

  this.get = () ->
    local_tables = localStorage.getItem('tables')
    if local_tables
      tables = JSON.parse(local_tables)
    return tables

  this.put = (tables) ->
    localStorage.setItem('tables', JSON.stringify(tables))

  return { data: this.get(), put: this.put}

services.factory 'Place', () ->
  place = {}

  this.get = () ->
    local_place = localStorage.getItem('place')

    if local_place
      place = JSON.parse(local_place)
    return place

  this.put = (place) ->
    localStorage.setItem('place', JSON.stringify(place))

  return { data: this.get(), put: this.put }

services.service('Data', () ->
  this.get = () ->
    return { message: "I'm data from a service" }

  return this.get()
)
