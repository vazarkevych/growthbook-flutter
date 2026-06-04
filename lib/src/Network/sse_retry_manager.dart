import 'dart:math';

class SSERetryManager {
  SSERetryManager({
    this.maxRetries = 10,
    this.initialRetryDelayMs = 1000,
    this.maxRetryDelayMs = 30000,
  });

  final int maxRetries;
  final int initialRetryDelayMs;
  final int maxRetryDelayMs;

  int _retryCount = 0;

  int get currentRetry => _retryCount;

  bool get shouldRetry => _retryCount < maxRetries;

  bool get isMaxRetriesReached => _retryCount >= maxRetries;

  Duration getBackoffDelay() {
    final exponentialDelay = initialRetryDelayMs * pow(2, _retryCount).toInt();
    final clampedDelay = min(exponentialDelay, maxRetryDelayMs);
    return Duration(milliseconds: clampedDelay);
  }

  void incrementRetry() => _retryCount++;

  void reset() => _retryCount = 0;
}
