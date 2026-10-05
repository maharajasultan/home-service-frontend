import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kabar "sesi berakhir" dari interceptor ke AuthController
/// (lewat stream, supaya tidak ada ketergantungan melingkar antar provider).
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});