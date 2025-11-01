import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/navigation/app_router.dart';

void main() {
  // Wrap the entire app in a ProviderScope
  // This is what allows all widgets to read our providers.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the routerProvider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RMS Tenant App',
      // Set the router configuration
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}