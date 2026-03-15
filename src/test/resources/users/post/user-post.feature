Feature: Create posts

  Background:
    * url api.baseUrl

  @Smoke @POST
  Scenario: Create a post successfully
    * def requestBody = read('classpath:users/post/post-request.json')
    Given path '/posts'
    And request requestBody
    When method post
    Then status 201
    And match response == read('classpath:common/schemas/post-schema.json')
    And match response.title == requestBody.title
    And match response.body == requestBody.body
    And match response.userId == requestBody.userId

  @Regression @POST
  Scenario Outline: Create posts for different users
    Given path '/posts'
    And request { title: '<title>', body: 'automated test content', userId: <userId> }
    When method post
    Then status 201
    And match response.userId == <userId>
    And match response.title == '<title>'

    Examples:
      | title             | userId |
      | Post from QA      | 1      |
      | Post from Leader  | 2      |
      | Post from Dev     | 3      |

  # NOTA: JSONPlaceholder es permisivo y no valida el body del request.
  # En una API real, los siguientes escenarios retornarían 400/422.
  # Se dejan comentados como referencia del patrón para APIs con validación real.
  #
  # @Regression @Negative @POST
  # Scenario: Create post with empty body returns 400
  #   Given path '/posts'
  #   And request {}
  #   When method post
  #   Then status 400
  #   And match response.error == '#string'
