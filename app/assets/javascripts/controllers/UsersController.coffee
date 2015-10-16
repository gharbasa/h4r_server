controllers = angular.module('controllers')
controllers.controller("UsersController", [ '$scope', '$routeParams', '$location', '$resource',
  ($scope,$routeParams,$location,$resource)->
    $scope.search = (keywords)->  $location.path("/").search('name',keywords)
    User = $resource('/api/1/users/:userId', { userId: "@id", format: 'json' })
    
    if $routeParams.name
      User = $resource('/api/1/users/search', { format: 'json' })
      User.query(name: $routeParams.name, (results)-> $scope.users = results)
    else
      $scope.users = []
      
    $scope.view = (userId)-> 
      $location.path("/api/1/users/#{userId}")
    
    $scope.newUser = -> $location.path("/api/1/users/new")
    
    $scope.edit      = (userId)-> $location.path("/api/1/users/#{userId}/edit")
])