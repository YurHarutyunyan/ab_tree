class Environment {
  // Check if running in development mode
  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  // API Base URL
  static String get apiBaseUrl {
    if (isDevelopment) {
      // For local development
      return 'http://localhost:3000';
    } else {
      // For production - replace with your actual production URL
      return 'https://your-production-server.com';
    }
  }

  // Environment name
  static String get environmentName => isDevelopment ? 'Development' : 'Production';
}
