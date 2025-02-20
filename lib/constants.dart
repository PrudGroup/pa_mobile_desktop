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

  static const String b2Key = String.fromEnvironment(
    'BACKBLAZE_KEY',
    defaultValue: '',
  );

  static const String apiStatues = String.fromEnvironment(
    'ALL_API_STATUS',
    defaultValue: '',
  );

  static const String paystackSecretTest = String.fromEnvironment(
    'PAYSTACK_SECRET_TEST',
    defaultValue: '',
  );

  static const String paystackSecretLive = String.fromEnvironment(
    'PAYSTACK_SECRET_LIVE',
    defaultValue: '',
  );
  static const String paystackPublicTest = String.fromEnvironment(
    'PAYSTACK_PUBLIC_TEST',
    defaultValue: '',
  );

  static const String paystackPublicLive = String.fromEnvironment(
    'PAYSTACK_PUBLIC_LIVE',
    defaultValue: '',
  );

}