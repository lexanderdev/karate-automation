function fn() {
    karate.configure('connectTimeout', 7000);
    karate.configure('readTimeout', 7000);
    karate.configure('ssl', true);

    var env = karate.env || 'dev';
    karate.log('karate.env:', env);

    var envConfig = read('classpath:karate-config-' + env + '.js');

    // NOTA: logModifier en Karate 1.x requiere una clase Java que implemente HttpLogModifier.
    // Para activarlo en producción, crear SensitiveDataModifier.java e invocar así:
    // karate.configure('logModifier', Java.type('utils.SensitiveDataModifier').INSTANCE);

    return karate.merge({ env: env }, envConfig);
}
