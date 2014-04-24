// Generated by CoffeeScript 1.6.3
(function() {
  'use strict';
  angular.module('myApp', ['ngRoute', 'myApp.filters', 'myApp.services', 'myApp.directives', 'myApp.controllers']).config([
    '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
      $routeProvider.when('/', {
        templateUrl: 'app/partials/partial1.html',
        controller: 'MainCtrl'
      });
      return $routeProvider.otherwise({
        redirectTo: '/'
      });
    }
  ]);

  window.services = angular.module('myApp.services', []);

  window.directives = angular.module('myApp.directives', []);

}).call(this);