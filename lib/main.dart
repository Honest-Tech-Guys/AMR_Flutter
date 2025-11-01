import 'dart:io'; // 1. IMPORT DART:IO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/navigation/app_router.dart';

// 2. ADD THIS CLASS (It tells Flutter to ignore all SSL errors)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // 3. ADD THIS LINE (to activate the override)
  HttpOverrides.global = MyHttpOverrides();
  
  // This is your existing code
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RMS Tenant App',
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}