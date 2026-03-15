package users;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ManagementUserTest {

    @Test
    void testParallel() {
        Results results = Runner
                .path("classpath:users", "classpath:common")
                .outputCucumberJson(true)
                .tags("~@Ignore")
                .parallel(4);

        generateReport(results.getReportDir());

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[]{"json"}, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));

        Configuration config = new Configuration(new File("build"), "Users API Tests");
        config.setBuildNumber(System.getenv("BUILD_NUMBER") != null ? System.getenv("BUILD_NUMBER") : "local");
        config.addClassifications("Environment", System.getProperty("karate.env", "dev"));
        config.addClassifications("Branch", System.getenv("GIT_BRANCH") != null ? System.getenv("GIT_BRANCH") : "local");

        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }
}
