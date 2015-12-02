angular.module 'rallytap.tabs', [
    'ui.router'
  ]
  .config ($stateProvider, $urlRouterProvider) ->
    $stateProvider.state 'tabs',
      url: '/tabs'
      abstract: true
      templateUrl: 'app/tabs/tabs.html'

    # Abstract tab states
    $stateProvider.state 'home',
      abstract: true
      url: '/home'
      parent: 'tabs'
      views:
        home:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'chats',
      abstract: true
      url: '/chats'
      parent: 'tabs'
      views:
        chats:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'post',
      abstract: true
      url: '/post'
      parent: 'tabs'
      views:
        post:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'saved',
      abstract: true
      url: '/saved'
      parent: 'tabs'
      views:
        saved:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'friends',
      abstract: true
      url: '/friends'
      parent: 'tabs'
      views:
        friends:
          template: '<ion-nav-view></ion-nav-view>'

    # Default tab
    #$urlRouterProvider.otherwise '/tabs/home'
