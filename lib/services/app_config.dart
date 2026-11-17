class AppConfig {
  const AppConfig._();

  static const wordpressBaseUrl = 'https://realtyeasy.sitesavvvy.com';
  static const propertiesPath = '/wp-json/rebs/v1/properties';
  static const leadsPath = '/wp-json/rebs/v1/leads';
  static const authLoginPath = '/wp-json/rebs/v1/auth/login';
  static const authRegisterPath = '/wp-json/rebs/v1/auth/register';
  static const authMePath = '/wp-json/rebs/v1/auth/me';
  static const savedPropertiesPath = '/wp-json/rebs/v1/saved-properties';

  static Uri endpoint(String path) => Uri.parse('$wordpressBaseUrl$path');
}
