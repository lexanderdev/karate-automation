Feature: Get users

  Background:
    * url api.baseUrl

  @Smoke @GET
  Scenario: Get a single user successfully
    Given path '/users/2'
    When method get
    Then status 200
    And match response.id == 2
    And match response == read('classpath:common/schemas/user-schema.json')

  @Regression @GET
  Scenario: Get user list validates structure with fuzzy matching
    Given path '/users'
    When method get
    Then status 200
    And match $ == '#[]'

    And assert response.length >= 1
    And match $[0] == read('classpath:common/schemas/user-schema.json')

  @Regression @GET
  Scenario: Get user list validates count and each element matches schema
    Given path '/users'
    When method get
    Then status 200
    * def schema = read('classpath:common/schemas/user-schema.json')
    And assert response.length == 10
    And match each response == schema

  @Regression @Negative @GET
  Scenario Outline: Get user returns expected HTTP status
    Given path '/users/<id>'
    When method get
    Then status <expectedStatus>

    Examples:
      | id  | expectedStatus |
      | 1   | 200            |
      | 10  | 200            |
      | 999 | 404            |
