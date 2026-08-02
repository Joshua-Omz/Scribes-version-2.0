import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'scribes',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('Using ${result.chosenImplementation} due to unsupported browser features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}
