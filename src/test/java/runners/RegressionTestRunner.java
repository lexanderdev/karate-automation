package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Suite de regresión completa. Ejecuta todos los escenarios excepto @Ignore.
 * Corre con mayor paralelismo para reducir tiempo total en CI.
 *
 * Uso: ./gradlew test --tests runners.RegressionTestRunner
 * Con env: ./gradlew test --tests runners.RegressionTestRunner -Dkarate.env=staging
 */
public class RegressionTestRunner {

    @Test
    void regressionTests() {
        Results results = Runner
                .path("classpath:users", "classpath:common")
                .tags("~@Ignore")
                .outputCucumberJson(true)
                .parallel(8);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
