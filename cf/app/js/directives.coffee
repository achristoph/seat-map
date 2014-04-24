cellSize = 25
canvasWidth = 375
canvasHeight = 375

initSeats = (tables) ->
  for k,v of tables
    s = tables[k]
    s.style =
      position: 'absolute'
      top: "#{s.row * cellSize}px"
      left: "#{s.column * cellSize}px"
      width: "#{(s.width * cellSize)}px"
      height: "#{(s.height * cellSize)}px"
      "line-height": "#{(s.height * cellSize)}px"

directives.directive "searchPlace", (Tables) ->
  return {
  restrict: "A",
  link: (scope, el, attrs) ->
    el.popover({trigger: 'manual'})
    options = { types: ['establishment'] }
    autocomplete = new google.maps.places.Autocomplete(el[0], options)

    navigator.geolocation.getCurrentPosition((position)->
      loc = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      bounds = new google.maps.LatLngBounds(loc, loc)
      #point to current location
      autocomplete.setBounds(bounds)
    )

    google.maps.event.trigger(autocomplete, 'place_changed')

    google.maps.event.addListener autocomplete, 'place_changed', ()->
      place = autocomplete.getPlace()
      scope.savePlace(place)

      if(place.geometry)
        scope.$apply () -> #trigger show result on ng-view place variable
          scope.place = place
          scope.getTables(place)
        el.popover('hide')
      else
        el.popover('show')

    $(document).click () ->
      el.popover('hide')
    # hide popup label

    $('#loc-me-btn').click () ->
      if !$('#loc-me-btn').hasClass('active')
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
  }

directives.directive "cellPanel", () ->
  return {
  restrict: "E"
  link: (scope, el, attrs) ->
    name = $(".selectedCell").attr("name")
    $("#square").change ()->
      $(".selectedCell").removeClass("circle")

    $("#circle").change ()->
      $(".selectedCell").addClass("circle")

    $("#openCellPanel").click () ->
      $("#openCellPanel").hide("slide")
      $("#cellPanel").toggle("slide")
    $("#cellPanelCloseBtn").click () ->
      $("#cellPanel").toggle("slide")
      $("#openCellPanel").show("slide")
  }

directives.directive "zoom", (Tables) ->
  return {
  restrict: "A",
  link: (scope, el, attrs) ->
    el.click (e) ->
      if attrs.zoom == 'in'
        $("#zoom-in").attr("disabled", false)
        $("#zoom-out").attr("disabled", false)
        cellSize = cellSize + 5
      else if attrs.zoom == 'out'
        $("#zoom-out").attr("disabled", false)
        $("#zoom-in").attr("disabled", false)
        cellSize = cellSize - 5
      if (cellSize >= 30)
        $("#zoom-in").attr("disabled", true)
      else if (cellSize <= 10)
        $("#zoom-out").attr("disabled", true)

      grid = document.getElementById('grid')
      grid.width = grid.width

      #reset canvas
      context = grid.getContext("2d")
      drawGridLine(context)
      initSeats(Tables.data)
      scope.$apply()

      $("cell").each () ->
        $(this).draggable("option", "grid", [cellSize, cellSize])

      $("cell").each () ->
        $(this).resizable("option", "grid", [cellSize, cellSize])
  }

directives.directive "cell", ($compile, Tables) ->
  return {
  restrict: "E"
  template: "<div ng-bind='table.qty'></div>"
  scope: true
  link: (scope, el, attrs) ->
    el.draggable
      stop: () ->
        x = (el.context.offsetLeft)
        y = (el.context.offsetTop)
        column  = Math.round(x / cellSize)
        row = Math.round(y / cellSize)
        t = scope.saveTablePosition(attrs.name, row, column)
        t.style =
          position: 'absolute'
          top: "#{t.row * cellSize}px"
          left: "#{t.column * cellSize}px"
          width: "#{(t.width * cellSize)}px"
          height: "#{(t.height * cellSize)}px"
          "line-height": "#{(t.height * cellSize)}px"
        t.class = "#{t.class} selected-cell"
        #select the cell again
        scope.$apply() #needed to refresh table otherwise inconsistent error occurs when dragging: late style refresh
      grid: [cellSize, cellSize]
      containment: "#grid"

    el.resizable
      grid: [cellSize, cellSize],
      autoHide: true,
      containment: "#grid",
      stop: () ->
        w = Math.round(el.width() / cellSize)
        h = Math.round(el.height() / cellSize)
        scope.saveTableSize(attrs.name, w, h)
      resize: () ->
        w = Math.round(el.width() / cellSize)
        h = Math.round(el.height() / cellSize)
        el.css("line-height", "#{el.height()}px")
        #resize hack for grid option problem with cell border existence
        el.width((w * cellSize) - 2)
        el.height((h * cellSize) - 2)

    el.mousedown (e) ->
      if (e.which == 1)
        x = e.currentTarget.offsetLeft
        y = e.currentTarget.offsetTop
        w = e.currentTarget.clientWidth
        h = e.currentTarget.clientHeight

        $(".selected-cell").removeClass("selected-cell")

        el.toggleClass("selected-cell")

        if el.hasClass("circle")
          $("#circle-btn").button('toggle')
        else
          $("#square-btn").button('toggle')

  #     scope.$parent.$parent.table = Tables[attrs.name] #refers to $scope.table on controller
  }

directives.directive "grid", ($compile, Tables) ->
  return {
  restrict: "A"
  link: (scope, el, attrs) ->
    context = el.get(0).getContext("2d")
    drawGridLine(context)

    $("#frame").on "contextmenu", (e) ->
      return false

    initSeats(Tables.data)

    el.mousedown (e) =>
      if (e.which == 1)
        x = e.pageX - $("#frame")[0].offsetLeft
        y = e.pageY - $("#frame")[0].offsetTop

        column = Math.floor(x / cellSize)
        row = Math.floor(y / cellSize)

        table =
          name: row + '-' + column
          qty: 0
          row: row
          column: column
          width: 1
          height: 1

        table.style =
          position: 'absolute'
          top: "#{table.row * cellSize}px"
          left: "#{table.column * cellSize}px"
          width: "#{(table.width * cellSize)}px"
          height: "#{(table.height * cellSize)}px"

        if $("#circle-btn").hasClass('active')
          table.class = "circle"
        else
          table.class = "square"
        scope.addTable(table)
        scope.$apply()
  }

drawGridLine = (context) ->
  for x in [0..canvasWidth] by cellSize
    context.moveTo(0.5 + x, 0)
    context.lineTo(0.5 + x, canvasHeight)

  #last vertical line
  context.moveTo(canvasWidth, 0)
  context.lineTo(canvasWidth, canvasHeight)

  #horizontal lines
  for y in [0..canvasHeight] by cellSize
    context.moveTo(0, 0.5 + y)
    context.lineTo(canvasWidth, 0.5 + y)

  #last horizontal line
  context.moveTo(0, canvasHeight)
  context.lineTo(canvasWidth, canvasHeight)

  context.strokeStyle = "#ccc"
  context.stroke()
  context.fillStyle = "#000"

