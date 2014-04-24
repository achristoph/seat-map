'use strict'

angular.module('myApp', ['ngRoute','myApp.filters', 'myApp.services', 'myApp.directives', 'myApp.controllers'])
.
config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider.when('/', {
    templateUrl: 'app/partials/partial1.html',
    controller: 'MainCtrl'
    }
  )
  $routeProvider.otherwise({redirectTo: '/'})
])

window.services = angular.module('myApp.services', [])
window.directives = angular.module('myApp.directives', [])
