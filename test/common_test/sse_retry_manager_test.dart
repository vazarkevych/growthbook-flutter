import 'package:flutter_test/flutter_test.dart';
import 'package:growthbook_sdk_flutter/src/Network/sse_retry_manager.dart';

void main() {
  group('SSERetryManager', () {
    test('initial state allows retry', () {
      final manager = SSERetryManager();
      expect(manager.shouldRetry, isTrue);
      expect(manager.isMaxRetriesReached, isFalse);
      expect(manager.currentRetry, 0);
    });

    test('getBackoffDelay increases exponentially', () {
      final manager = SSERetryManager(initialRetryDelayMs: 1000);

      expect(manager.getBackoffDelay(), const Duration(milliseconds: 1000));
      manager.incrementRetry();
      expect(manager.getBackoffDelay(), const Duration(milliseconds: 2000));
      manager.incrementRetry();
      expect(manager.getBackoffDelay(), const Duration(milliseconds: 4000));
      manager.incrementRetry();
      expect(manager.getBackoffDelay(), const Duration(milliseconds: 8000));
    });

    test('getBackoffDelay does not exceed maxRetryDelayMs', () {
      final manager = SSERetryManager(
        initialRetryDelayMs: 1000,
        maxRetryDelayMs: 5000,
      );

      for (int i = 0; i < 10; i++) {
        manager.incrementRetry();
      }

      expect(manager.getBackoffDelay(), const Duration(milliseconds: 5000));
    });

    test('isMaxRetriesReached after maxRetries increments', () {
      final manager = SSERetryManager(maxRetries: 3);

      expect(manager.shouldRetry, isTrue);
      manager.incrementRetry();
      manager.incrementRetry();
      manager.incrementRetry();
      expect(manager.isMaxRetriesReached, isTrue);
      expect(manager.shouldRetry, isFalse);
    });

    test('reset clears retry count', () {
      final manager = SSERetryManager(maxRetries: 3);
      manager.incrementRetry();
      manager.incrementRetry();
      manager.incrementRetry();
      expect(manager.isMaxRetriesReached, isTrue);

      manager.reset();

      expect(manager.currentRetry, 0);
      expect(manager.shouldRetry, isTrue);
      expect(manager.isMaxRetriesReached, isFalse);
    });
  });
}
