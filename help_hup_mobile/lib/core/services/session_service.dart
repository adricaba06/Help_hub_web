import 'dart:async';

class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();

  Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  void notifyUnauthorized() {
    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.add(null);
    }
  }
}
