/// Environment variables and shared app constants.
abstract class Constants {
  static const String localApiUrl = String.fromEnvironment(
    'LOCAL_API_URL',
    defaultValue: '',
  );

  static const String prudApiUrl = String.fromEnvironment(
    'PRUD_API_URL',
    defaultValue: '',
  );

  static const String envType = String.fromEnvironment(
    'ENV_TYPE',
    defaultValue: '',
  );

  static const String prudApiKey = String.fromEnvironment(
    'PRUD_API_KEY',
    defaultValue: '',
  );

  static const String fireApiKey = String.fromEnvironment(
    'FIRE_API_KEY',
    defaultValue: '',
  );

  static const String fireAppID = String.fromEnvironment(
    'FIRE_APP_ID',
    defaultValue: '',
  );

  static const String fireAndroidAppID = String.fromEnvironment(
    'FIRE_ANDROID_APP_ID',
    defaultValue: '',
  );

  static const String fireIOSAppID = String.fromEnvironment(
    'FIRE_IOS_APP_ID',
    defaultValue: '',
  );

  static const String fireMessageID = String.fromEnvironment(
    'FIRE_MSG_ID',
    defaultValue: '',
  );

  static const String wavePublicKey = String.fromEnvironment(
    'WAVE_PUBLIC_KEY',
    defaultValue: '',
  );

  static const String waveSecretKey = String.fromEnvironment(
    'WAVE_SECRET_KEY',
    defaultValue: '',
  );

  static const String reloadlyTestSecretKey = String.fromEnvironment(
    'RELOADLY_TEST_CLIENT_SECRET',
    defaultValue: '',
  );

  static const String reloadlyTestClientId = String.fromEnvironment(
    'RELOADLY_TEST_CLIENT_ID',
    defaultValue: '',
  );

  static const String reloadlyLiveSecretKey = String.fromEnvironment(
    'RELOADLY_LIVE_CLIENT_SECRET',
    defaultValue: '',
  );

  static const String reloadlyLiveClientId = String.fromEnvironment(
    'RELOADLY_LIVE_CLIENT_ID',
    defaultValue: '',
  );

  static const String apiStatues = String.fromEnvironment(
    'ALL_API_STATUS',
    defaultValue: '',
  );

}