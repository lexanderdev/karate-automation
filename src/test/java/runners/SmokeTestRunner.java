package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Suite rápida de sanity check. Solo ejecuta escenarios marcados con @Smoke.
 * Ideal para correr en cada PR o deploy antes de regression completa.
 *
 * Uso: ./gradlew test --tests runners.SmokeTestRunner
 */
public class SmokeTestRunner {

    @Test
    void smokeTests() {
        Results results = Runner
                .path("classpath:users")
                .tags("@Smoke", "~@Ignore")
                .outputCucumberJson(true)
                .parallel(2);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
