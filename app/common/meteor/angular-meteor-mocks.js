var angularMeteor = angular.module('angular-meteor', []);
angularMeteor.service('$meteor', function(){
  this.collection = jasmine.createSpy('$meteorCollection');                                                 
  this.collectionFS = jasmine.createSpy('$meteorCollectionFS');                                             
  this.object = jasmine.createSpy('$meteorObject');                                                         
  this.subscribe = jasmine.createSpy('$meteorSubscribe.subscribe');                                         
  this.call = jasmine.createSpy('$meteorMethods.call');                                                     
  this.loginWithPassword = jasmine.createSpy('$meteorUser.loginWithPassword');                              
  this.requireUser = jasmine.createSpy('$meteorUser.requireUser');                                          
  this.requireValidUser = jasmine.createSpy('$meteorUser.requireValidUser');                                
  this.waitForUser = jasmine.createSpy('$meteorUser.waitForUser');                                          
  this.createUser = jasmine.createSpy('$meteorUser.createUser');                                            
  this.changePassword = jasmine.createSpy('$meteorUser.changePassword');                                    
  this.forgotPassword = jasmine.createSpy('$meteorUser.forgotPassword');                                    
  this.resetPassword = jasmine.createSpy('$meteorUser.resetPassword');                                      
  this.verifyEmail = jasmine.createSpy('$meteorUser.verifyEmail');                                          
  this.loginWithMeteorDeveloperAccount = jasmine.createSpy('$meteorUser.loginWithMeteorDeveloperAccount');  
  this.loginWithFacebook = jasmine.createSpy('$meteorUser.loginWithFacebook');                              
  this.loginWithGithub = jasmine.createSpy('$meteorUser.loginWithGithub');                                  
  this.loginWithGoogle = jasmine.createSpy('$meteorUser.loginWithGoogle');                                  
  this.loginWithMeetup = jasmine.createSpy('$meteorUser.loginWithMeetup');                                  
  this.loginWithTwitter = jasmine.createSpy('$meteorUser.loginWithTwitter');                                
  this.loginWithWeibo = jasmine.createSpy('$meteorUser.loginWithWeibo');                                    
  this.logout = jasmine.createSpy('$meteorUser.logout');                                                    
  this.logoutOtherClients = jasmine.createSpy('$meteorUser.logoutOtherClients');                            
  this.session = jasmine.createSpy('$meteorSession');                                                       
  this.autorun = jasmine.createSpy('$meteorUtils.autorun');                                                 
  this.getCollectionByName = jasmine.createSpy('$meteorUtils.getCollectionByName');                         
  this.getPicture = jasmine.createSpy('$meteorCamera.getPicture');  
});