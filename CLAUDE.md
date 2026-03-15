# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Suite principal (ManagementUserTest, 4 hilos)
./gradlew test

# Solo smoke tests — rápido, ideal para PRs y pre-deploy
./gradlew smoke

# Regresión completa — CI / nightly (8 hilos)
./gradlew regression

# Cualquier tarea contra un ambiente específico
./gradlew test -Dkarate.env=staging
./gradlew smoke -Dkarate.env=prod
./gradlew regression -Dkarate.env=staging

# Reporte de cobertura (output: build/reports/jacoco/test/html/)
./gradlew jacocoTestReport
```

> **Importante**: `smoke` y `regression` están excluidos del task `test` para evitar conflictos de
> concurrencia. Ejecutarlos por separado, no en paralelo con `./gradlew test`.

## Architecture

Proyecto de automatización de pruebas de API con **Karate Framework** (Java 21, Gradle). Usa JSONPlaceholder como API demo para CRUD de users/posts y reqres.in para el flujo de autenticación.

### Test Execution Flow

- **Runner principal**: `ManagementUserTest.java` — corre todo bajo `classpath:users` y `classpath:common`, excluye `@Ignore`, genera reporte Cucumber enriquecido.
- **SmokeTestRunner**: solo tags `@Smoke`, 2 hilos — para PRs y deploys rápidos.
- **RegressionTestRunner**: todos los escenarios, 8 hilos — para CI/nightly.
- Feature files se descubren desde `src/test/resources/` (configurado en `sourceSets` de `build.gradle`).

### Project Structure

```
src/test/
├── java/
│   ├── runners/
│   │   ├── SmokeTestRunner.java       # @Smoke, 2 hilos
│   │   └── RegressionTestRunner.java  # todos, 8 hilos
│   └── users/
│       └── ManagementUserTest.java    # runner principal con reporte Cucumber
└── resources/
    ├── karate-config.js               # config base: timeouts, logModifier, carga env-config
    ├── karate-config-dev.js           # URLs para DEV (default)
    ├── karate-config-staging.js       # URLs para STAGING
    ├── karate-config-prod.js          # URLs para PROD
    ├── common/
    │   ├── auth.feature               # flujo de autenticación reutilizable (callonce)
    │   └── schemas/
    │       ├── user-schema.json       # schema fuzzy reutilizable para users
    │       └── post-schema.json       # schema fuzzy reutilizable para posts
    └── users/
        ├── e2e/
        │   └── user-crud-flow.feature # flows end-to-end encadenados
        ├── get/user-get.feature
        ├── post/
        │   ├── user-post.feature
        │   └── post-request.json      # body de request como archivo separado
        └── delete/user-delete.feature
```

### Key Files

| File | Purpose |
|------|---------|
| `karate-config.js` | Carga el env-config correspondiente, activa `logModifier` para enmascarar tokens/passwords |
| `karate-config-{env}.js` | Define `api.baseUrl` y `api.authUrl` por ambiente |
| `common/auth.feature` | Obtiene token de reqres.in; llamar con `callonce` para cachear en la sesión |
| `common/schemas/*.json` | Schemas de fuzzy matching reutilizables en cualquier feature con `read()` |
| `ManagementUserTest.java` | Genera reporte con metadata de ambiente, branch y build number |

### Tagging Strategy

| Tag | Uso |
|-----|-----|
| `@Smoke` | Happy path mínimo — PRs y pre-deploy |
| `@Regression` | Suite completa |
| `@Negative` | Casos de error esperados (4xx) |
| `@E2E` | Flujos multi-step encadenados |
| `@GET` / `@POST` / `@DELETE` | Filtrar por operación HTTP |
| `@Ignore` | Excluir del runner automático (ej. features reutilizables con `callonce`) |

### Patterns Used

**Environment config**: `karate.env` → carga `karate-config-{env}.js` → disponible como `api.baseUrl` y `api.authUrl` en todos los features.

**Reusable auth**: features que requieren auth llaman `* def auth = callonce read('classpath:common/auth.feature')` en el Background y usan `auth.token`.

**Schema reuse**: en lugar de inline fuzzy matching, los features usan `match response == read('classpath:common/schemas/user-schema.json')`.

**Request data**: los bodies de request están en archivos JSON separados bajo el directorio del feature (`post-request.json`), no inline en el `.feature`.
