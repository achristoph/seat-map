angular.module('myApp.filters', []).filter('reverse', () ->
  (text) ->
    if text
      text.split("").reverse().join("")
)

