describe 'controllers', () ->
  beforeEach(module('myApp.controllers'))

  describe 'FirstCtrl', () ->
    scope = null
    beforeEach ( inject ($rootScope) ->
      scope = $rootScope.$new()
    )

    describe 'the watch on foo', () ->
      it 'should fire when foo changes', inject ($controller, $log) ->
        spyOn($log, 'log')
        scope.$apply () ->
          $controller 'FirstCtrl',
            $scope: scope,
            $log: $log
        expect(scope.foo).toBe('bar')
        scope.$apply("foo = 'baz'")
        expect(scope.foo).toBe('baz')
