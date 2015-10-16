controllers = angular.module('controllers')
controllers.controller("UserController", [ '$scope', '$routeParams', '$resource', '$location', 'flash',
  ($scope,$routeParams,$resource,$location, flash)->
    User = $resource('/api/1/users/:userId', 
                      { 
                          userId: "@id", 
                          format: 'json' 
                      },
                      {
                        'save'  : {method:'PUT'},
                        'create': {method:'POST'},
                        'delete': {method:'DELETE'}
                        #,
                        #'remove': { 
                        #             method:'DELETE',
                        #             url: '/api/1/users/:id',
                        #             id: '@id'
                        #          }
                      }
                    )

    
    User.get(
            {userId: $routeParams.userId}, 
            ( (user)-> 
              $scope.user = user.user ),
            ( (httpResponse)-> 
              $scope.user = null
              flash.error   = "There is no user with ID #{$routeParams.userId}"
            )
          )
    
    
    $scope.back = -> $location.path("/")
    
    $scope.edit   = -> $location.path("/api/1/users/#{$scope.user.id}/edit")
    $scope.cancel = ->
      if $scope.user.id
        $location.path("/api/1/users/#{$scope.user.id}")
      else
        $location.path("/")

    $scope.save = ->
      onError = (_httpResponse)-> flash.error = "Something went wrong" //TODO: have to find what went wrong(may be session timeout)
      if $scope.user.id
        $scope.user.$save(
          ( ()-> $location.path("/api/1/users/#{$scope.user.id}") ),
            onError)
      else
        User.create($scope.user,
          ( (newUser)-> $location.path("/api/1/users/#{newUser.user.id}") ),
            onError
        )

    $scope.delete = ->
      #$scope.user.$delete()
      User.delete({userId: $scope.user.id})
      #User.remove({userId: $scope.user.id})
      $scope.back()
])