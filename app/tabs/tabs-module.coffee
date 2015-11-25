angular.module 'rallytap.tabs', [
    'ui.router'
  ]
  .config ($stateProvider, $urlRouterProvider) ->
    $stateProvider.state 'tabs',
      url: '/tabs'
      abstract: true
      templateUrl: 'app/tabs/tabs.html'

    # Abstract tab states
    $stateProvider.state 'tabs.home',
      abstract: true
      url: '/home'
      views:
        home:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'tabs.chats',
      abstract: true
      url: '/chats'
      views:
        chats:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'tabs.post',
      abstract: true
      url: '/post'
      views:
        post:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'tabs.saved',
      abstract: true
      url: '/saved'
      views:
        saved:
          template: '<ion-nav-view></ion-nav-view>'
    $stateProvider.state 'tabs.friends',
      abstract: true
      url: '/friends'
      views:
        friends:
          template: '<ion-nav-view></ion-nav-view>'
    
    # Default tab
    #$urlRouterProvider.otherwise '/tabs/home'