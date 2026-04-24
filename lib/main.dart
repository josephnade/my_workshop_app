import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:learn_again_flutter/features/home/presentation/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data with error handling
  try {
    await initializeDateFormatting('tr_TR');
  } catch (e) {
    debugPrint('Error initializing date formatting: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); // Refers to generated provider

    return MaterialApp(
      title: 'Productivity App',
      debugShowCheckedModeBanner: false,
      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
