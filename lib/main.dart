import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/local_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local-first: everything lives on device until a backend is introduced.
  await HiveService.init();
  await LocalSeed.runIfNeeded();

  runApp(const ProviderScope(child: ForYouApp()));
}
