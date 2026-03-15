# Proyecto Base de Pruebas API con Karate

Arquetipo de pruebas de API REST usando [Karate Framework](https://github.com/karatelabs/karate). Implementa configuración multi-ambiente, runners especializados, schemas reutilizables, flujos E2E, enmascarado de datos sensibles y CI/CD con GitHub Actions.

## Tecnologías

| Tecnología | Versión |
|------------|---------|
| Java | 21+ |
| Gradle | 8.x |
| Karate Framework | 1.4.1 |
| Cucumber Reporting | 5.7.7 |
| JaCoCo | Plugin Gradle |

## Prerequisitos

- **Java 21+** instalado y `JAVA_HOME` configurado
- **Gradle Wrapper** incluido en el proyecto (no se requiere instalación adicional)

Verificar instalación:
```bash
java -version   # debe mostrar 21+
./gradlew -v    # debe mostrar Gradle 8.x
```

## Instalación

```bash
git clone <url-del-repo>
cd Karate
./gradlew build
```

## Ejecución de Pruebas

### Suite principal
Corre todos los escenarios con `ManagementUserTest` (4 hilos en paralelo):
```bash
./gradlew test
```

### Smoke — sanity check rápido
Solo escenarios `@Smoke`. Ideal para validar antes de un deploy:
```bash
./gradlew smoke
```

### Regression — suite completa
Todos los escenarios `~@Ignore` con 8 hilos en paralelo:
```bash
./gradlew regression
```

### Por ambiente
Cualquier task acepta `-Dkarate.env`:
```bash
./gradlew test       -Dkarate.env=dev      # default
./gradlew smoke      -Dkarate.env=staging
./gradlew regression -Dkarate.env=prod
```

### Reporte de cobertura
```bash
./gradlew jacocoTestReport
# Output: build/reports/jacoco/test/html/index.html
```

> **Nota:** `smoke` y `regression` son tasks independientes. No correr en paralelo con `./gradlew test`.

## Estructura del Proyecto

```
src/test/
├── java/
│   ├── runners/
│   │   ├── SmokeTestRunner.java       # @Smoke, 2 hilos — PRs y pre-deploy
│   │   └── RegressionTestRunner.java  # todos los escenarios, 8 hilos — CI/nightly
│   ├── users/
│   │   └── ManagementUserTest.java    # runner principal con reporte Cucumber enriquecido
│   └── utils/
│       └── SensitiveDataModifier.java # HttpLogModifier — enmascara tokens y passwords en logs
└── resources/
    ├── karate-config.js               # config base: carga env-config por ambiente
    ├── karate-config-dev.js           # URLs para DEV (default)
    ├── karate-config-staging.js       # URLs para STAGING
    ├── karate-config-prod.js          # URLs para PROD
    ├── common/
    │   ├── auth.feature               # flujo de autenticación reutilizable (callonce)
    │   └── schemas/
    │       ├── user-schema.json       # schema fuzzy para validación de usuarios
    │       └── post-schema.json       # schema fuzzy para validación de posts
    └── users/
        ├── e2e/
        │   └── user-crud-flow.feature # flujo E2E encadenado (GET → POST → DELETE)
        ├── get/user-get.feature
        ├── post/
        │   ├── user-post.feature
        │   └── post-request.json      # body del request separado del feature
        └── delete/user-delete.feature
```

## Configuración por Ambiente

El ambiente se controla con la propiedad `karate.env`. Cada ambiente tiene su propio archivo de configuración:

| Archivo | Ambiente | Activación |
|---------|----------|------------|
| `karate-config-dev.js` | Desarrollo (default) | `./gradlew test` |
| `karate-config-staging.js` | Staging | `-Dkarate.env=staging` |
| `karate-config-prod.js` | Producción | `-Dkarate.env=prod` |

Para apuntar a una API propia, editar el archivo del ambiente correspondiente:
```javascript
// karate-config-staging.js
function fn() {
    return {
        api: {
            baseUrl: 'https://staging.tu-api.com',
            authUrl: 'https://staging.tu-auth.com'
        }
    };
}
```

## Estrategia de Tags

Los escenarios están etiquetados para ejecución selectiva:

| Tag | Descripción |
|-----|-------------|
| `@Smoke` | Happy path mínimo — PRs y pre-deploy |
| `@Regression` | Suite completa |
| `@Negative` | Casos de error esperados (4xx) |
| `@E2E` | Flujos multi-step encadenados |
| `@GET` / `@POST` / `@DELETE` | Filtrar por operación HTTP |
| `@Ignore` | Excluido del runner automático |

## Seguridad y Datos Sensibles

`SensitiveDataModifier.java` implementa `HttpLogModifier` y enmascara automáticamente `password`, `token` y `Authorization` en los logs de Karate.

Para activarlo, descomentar en `karate-config.js`:
```javascript
karate.configure('logModifier', Java.type('utils.SensitiveDataModifier').INSTANCE);
```

**Regla:** nunca hardcodear credenciales reales. Usar variables de entorno en CI:
```yaml
- run: ./gradlew test -Dkarate.env=staging
  env:
    BASE_URL: ${{ secrets.STAGING_BASE_URL }}
```

## Autenticación

`common/auth.feature` implementa el flujo de login y cachea el token para toda la sesión:

```gherkin
# En cualquier feature que requiera auth:
Background:
  * def auth = callonce read('classpath:common/auth.feature')
  * header Authorization = 'Bearer ' + auth.token
```

## Reportes

| Reporte | Ubicación |
|---------|-----------|
| Karate HTML | `build/karate-reports/` |
| Cucumber HTML | `build/cucumber-html-reports/` |
| JaCoCo cobertura | `build/reports/jacoco/test/html/` |

Los reportes Cucumber incluyen metadata de ambiente, branch y build number cuando se ejecutan en CI.

## CI/CD

El pipeline de GitHub Actions (`.github/workflows/ci.yml`) se ejecuta en cada `push` y `pull_request`:

1. Setup Java 21
2. `./gradlew test` — suite principal
3. `./gradlew jacocoTestReport` — cobertura
4. Upload de reporte JaCoCo como artifact

## Contribuciones
data
1. Usar [Conventional Commits](https://www.conventionalcommits.org/): `test:`, `fix:`, `feat:`, `ci:`, `docs:`
2. Ejecutar `./gradlew smoke` antes de hacer push
3. Los nuevos features deben incluir al menos un escenario `@Smoke` y un escenario `@Negative`

## Roadmapgit add README.md

- [ ] Activar `SensitiveDataModifier` en ambientes de staging y prod
- [ ] Agregar escenarios de seguridad API (`@Security`): SQL injection, XSS, CORS
- [ ] Integrar pruebas de rendimiento con Karate Gatling
- [ ] OWASP Dependency Check en pipeline CI
