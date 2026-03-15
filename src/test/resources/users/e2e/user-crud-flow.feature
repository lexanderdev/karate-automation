Feature: End-to-end CRUD flow for posts

  Background:
    * url api.baseUrl

  @E2E @Regression
  Scenario: Full lifecycle - read, create, delete
    # Step 1: verificar que la lista de posts existe y tiene contenido
    Given path '/posts'
    When method get
    Then status 200
    And match $ == '#[]'
    * def totalPosts = response.length
    * print 'Total posts before create:', totalPosts

    # Step 2: crear un nuevo post
    * def newPost = { title: 'E2E Test Post', body: 'Created during E2E flow', userId: 1 }
    Given path '/posts'
    And request newPost
    When method post
    Then status 201
    And match response.title == newPost.title
    And match response.userId == newPost.userId
    * print 'Create response id:', response.id

    # Step 3: eliminar un post existente conocido
    # NOTA: JSONPlaceholder es una API mock — los recursos creados no persisten (siempre devuelve id: 101).
    # En una API real se usaría el id creado en el paso anterior.
    # Aquí usamos un id existente para demostrar el delete.
    Given path '/posts/50'
    When method delete
    Then status 200
    And match response == {}
    * print 'Delete of post/50 confirmed'

  # NOTA: reqres.in usa Cloudflare en producción y puede bloquear peticiones automatizadas.
  # Este escenario demuestra el patrón de auth con Bearer token.
  # Activar cuando se tenga una API propia con autenticación.
  @E2E @Ignore
  Scenario: Auth flow then consume protected endpoint
    # Step 1: autenticarse y obtener token
    * def auth = callonce read('classpath:common/auth.feature')
    * def token = auth.token
    * print 'Auth token obtained:', token != null

    # Step 2: usar el token en un request autenticado
    Given path '/users'
    And header Authorization = 'Bearer ' + token
    When method get
    Then status 200
    And match $ == '#[]'
