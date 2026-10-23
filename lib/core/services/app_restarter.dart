import 'dart:io';

/// Starts the app again. Used after a restore, because the database was replaced.
abstract class AppRestarter {
  Future<void> restart();
}

class ProcessAppRestarter implements AppRestarter {
  const ProcessAppRestarter();

  @override
  Future<void> restart() async {
    await Process.start(Platform.resolvedExecutable, const [], mode: ProcessStartMode.detached);
    exit(0);
  }
}
