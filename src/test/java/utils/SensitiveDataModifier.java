package utils;

import com.intuit.karate.http.HttpLogModifier;

/**
 * Enmascara datos sensibles en los logs de Karate.
 * Para activar, descomentar en karate-config.js:
 *   karate.configure('logModifier', Java.type('utils.SensitiveDataModifier').INSTANCE);
 */
public class SensitiveDataModifier implements HttpLogModifier {

    public static final SensitiveDataModifier INSTANCE = new SensitiveDataModifier();

    private static final String MASK = "***";

    @Override
    public boolean enableForUri(String uri) {
        return true;
    }

    @Override
    public String uri(String uri) {
        return uri;
    }

    @Override
    public String request(String uri, String payload) {
        return mask(payload);
    }

    @Override
    public String response(String uri, String payload) {
        return mask(payload);
    }

    @Override
    public String header(String name, String value) {
        if (name != null && name.equalsIgnoreCase("Authorization")) {
            return MASK;
        }
        return value;
    }

    private String mask(String text) {
        if (text == null) return null;
        return text
                .replaceAll("(?i)(\"password\"\\s*:\\s*)\"[^\"]*\"", "$1\"" + MASK + "\"")
                .replaceAll("(?i)(\"token\"\\s*:\\s*)\"[^\"]*\"", "$1\"" + MASK + "\"")
                .replaceAll("(?i)(\"authorization\"\\s*:\\s*)\"[^\"]*\"", "$1\"" + MASK + "\"");
    }
}
