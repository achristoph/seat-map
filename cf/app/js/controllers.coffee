'use strict'

angular.module('myApp.controllers', []).
controller('NavCtrl',($scope, Tables, Place, Data, $http) ->
  $scope.place = Place
  $scope.data = Data
  cellSize = 25
  $scope.getTables = (table) ->
    $http(
      url: '/table',
      method: "GET",
      params:
        {place_id: Place.data.id}
    ).success((tables, status, headers, config) ->
      console.log tables
      for k,v of tables
        s = tables[k]
        s.style =
          position: 'absolute'
          top: "#{s.row * cellSize}px"
          left: "#{s.column * cellSize}px"
          width: "#{(s.width * cellSize)}px"
          height: "#{(s.height * cellSize)}px"
          "line-height": "#{(s.height * cellSize)}px"
      Tables.data = tables
      Tables.put(tables)
    )

  $scope.savePlace = (place) ->
    Place.data = place
    Place.put(place)
).
controller('MainCtrl', ($scope, Tables, Place, Data, $http) ->
  $scope.place = Place
  $scope.tables = Tables
  $scope.message = ""
  $scope.data = Data

  $scope.locate = ()->
    if not autocomplete.bounds
      navigator.geolocation.getCurrentPosition(
        (position)->
          loc = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
          bounds = new google.maps.LatLngBounds(loc, loc)
          autocomplete.setBounds(bounds)
      ,
      ()->
        alert('error')
      )
    else
      autocomplete.setBounds(null)

  $scope.selectTable = (table) ->
    $scope.table = table
  #this will display the selected table on tablePanel

  $scope.saveTableQty = (table) ->
    Tables.data[table.name] = table
    Tables.put(Tables.data)

  $scope.addTable = (table) ->
    console.log table
    Tables.data[table.name] = table
    Tables.put(Tables.data)

  $scope.deleteTable = (table) ->
    delete Tables.data[table.name]
    Tables.put(Tables.data)

  #clear cellPanel
  $scope.saveTablePosition = (name, row, column) ->
    old_table = Tables.data[name]
    table = old_table
    new_name = "#{row}-#{column}"
    table.row = row
    table.column = column
    table.name = new_name
    Tables.data[new_name] = table
    delete Tables.data[name]
    #delete existing one, once the new one is created
    $scope.table = table
    Tables.put(Tables.data)
    return table

  $scope.saveTableSize = (name, w, h) ->
    table = Tables.data[name]
    table.width = w
    table.height = h
    $scope.table = table
    Tables.put(Tables.data)

  $scope.saveShape = (table, shape) ->
    if table
      table.class = shape
      Tables.data[table.name] = table
      Tables.put(Tables)

  $scope.saveTablesToDb = () ->
    Tables.put(Tables.data)
    console.log Tables

    if not _.isEmpty(Place.data)
      arr = {}
      arr['place'] = { 'id': Place.data.id, 'name': Place.data.name }
      arr['tables'] = Tables.data
      console.log arr

      $.post('/table', angular.toJson(arr), (data) ->
        $scope.message = "#{_.size(Tables.data)} tables saved"
        $scope.messageStyle = "alert alert-success"
        $scope.$apply()
      )
    else
      $scope.message = "A place not selected"
      $scope.messageStyle = "alert alert-danger"
)
