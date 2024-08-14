import 'package:sentry_flutter/sentry_flutter.dart';

import '../startup.dart';

class InitSentryTask extends LaunchTask {
  const InitSentryTask();

  @override
  Future<void> initialize(LaunchContext context) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = '';
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
    );
  }

  @override
  Future<void> dispose() async {}
}
