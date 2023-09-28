abstract class ILogger {
  Future<void> logError(Exception exception, StackTrace stackTrace);
}
