describe 'place-autocomplete', ->
  input = null

  # workaround for https://github.com/angular/protractor/issues/325
  browser.ignoreSynchronization = true

  beforeEach ->
    browser.get 'http://localhost:5000'

    # wait for the view to load
    browser.wait ->
      browser.isElementPresent(By.css '#landing').then (isPresent) -> isPresent
    , 2*1000, 'landing'

    input = element By.model('setLocations.location')

  describe 'typing a letter', ->

    beforeEach ->
      input.sendKeys 'a'

    it 'should show predictions', ->
      browser.wait ->
        browser.isElementPresent(By.css '.pac-item').then (isPresent) -> isPresent
      , 2*1000, 'predictions'
