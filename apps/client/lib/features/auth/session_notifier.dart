import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';

part 'session_notifier.g.dart';

/// Pseudo-auth: the "session" is just the user's name in shared_preferences.
@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  @override
  String? build() => ref.watch(sessionLocalDatasourceProvider).readUserName();

  Future<void> logIn(String name) async {
    await ref.read(sessionLocalDatasourceProvider).saveUserName(name.trim());
    ref.invalidateSelf();
  }

  Future<void> logOut() async {
    await ref.read(sessionLocalDatasourceProvider).clear();
    ref.invalidateSelf();
  }
}
