import 'package:flutter_test/flutter_test.dart';

bool shouldKeepRestoredSession({required bool syncSucceeded, required int? statusCode}) {
  if (syncSucceeded) return true;
  return statusCode != 401 && statusCode != 403;
}

void main() {
  test('keeps a session when saved-property sync is temporarily unavailable', () {
    expect(shouldKeepRestoredSession(syncSucceeded: false, statusCode: null), isTrue);
    expect(shouldKeepRestoredSession(syncSucceeded: false, statusCode: 500), isTrue);
  });

  test('rejects a session after authentication failure', () {
    expect(shouldKeepRestoredSession(syncSucceeded: false, statusCode: 401), isFalse);
    expect(shouldKeepRestoredSession(syncSucceeded: false, statusCode: 403), isFalse);
  });
}
