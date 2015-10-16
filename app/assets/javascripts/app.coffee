h4r = angular.module('h4r',[
  'templates',
  'ngRoute',
  'ngResource',
  'controllers',
  'angular-flash.service',
  'angular-flash.flash-alert-directive'
])

h4r.config([ '$routeProvider', 'flashProvider',
  ($routeProvider,flashProvider)->
    flashProvider.errorClassnames.push("alert-danger")
    flashProvider.warnClassnames.push("alert-warning")
    flashProvider.infoClassnames.push("alert-info")
    flashProvider.successClassnames.push("alert-success")
    
    $routeProvider
      .when('/',
        templateUrl: "index.html"
        controller: 'UsersController'
      ).when('/api/1/users/new',
        templateUrl: "userForm.html"
        controller: 'UserController'
      ).when('/api/1/users/:userId',
        templateUrl: "show.html"
        controller: 'UserController'
      ).when('/api/1/users/:userId/edit',
        templateUrl: "userForm.html"
        controller: 'UserController'  
      )
])

recipes = [
  {
    id: 1
    name: 'Baked Potato w/ Cheese'
  },
  {
    id: 2
    name: 'Garlic Mashed Potatoes',
  },
  {
    id: 3
    name: 'Potatoes Au Gratin',
  },
  {
    id: 4
    name: 'Baked Brussel Sprouts',
  },
]


controllers = angular.module('controllers',[])
