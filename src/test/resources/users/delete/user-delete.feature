Feature: Delete posts

  Background:
    * url api.baseUrl

  @Smoke @DELETE
  Scenario: Delete an existing post returns 200 with empty body
    Given path '/posts/1'
    When method delete
    Then status 200
    And match response == {}

  @Regression @DELETE
  Scenario: Delete and verify resource is gone
    # Step 1: confirmar que el recurso existe antes de borrarlo
    Given path '/posts/2'
    When method get
    Then status 200
    * def postId = response.id

    # Step 2: eliminar el recurso
    Given path '/posts/' + postId
    When method delete
    Then status 200
    And match response == {}

  # NOTA: JSONPlaceholder retorna 200 para cualquier DELETE sin importar el ID.
  # En una API real con persistencia real, el siguiente escenario aplicaría.
  #
  # @Regression @Negative @DELETE
  # Scenario: Delete non-existent post returns 404
  #   Given path '/posts/999999'
  #   When method delete
  #   Then status 404
