Feature: Authentication

  # Llamar con: * def auth = callonce read('classpath:common/auth.feature')
  # Luego usar: * header Authorization = 'Bearer ' + auth.token
  @Ignore
  Scenario: Get auth token
    Given url api.authUrl
    And path '/api/login'
    And request { email: 'eve.holt@reqres.in', password: 'cityslicka' }
    When method post
    Then status 200
    And match response.token == '#string'
    * def token = response.token
