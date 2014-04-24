describe 'filter', () ->
  beforeEach(module('myApp.filters'))

  describe 'reverse', () ->
    it 'should reverse a string', inject (reverseFilter) ->
      expect(reverseFilter('ABCD')).toEqual('DCBA')
