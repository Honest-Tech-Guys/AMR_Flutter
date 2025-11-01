import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/presentation/login_screen.dart';
import 'package:rms_tenant_app/features/auth/presentation/registration_screen.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_screen/home_screen.dart';
import 'package:rms_tenant_app/features/invoices/presentation/invoices_screen.dart';
import 'package:rms_tenant_app/features/profile/presentation/profile_screen.dart';
import 'package:rms_tenant_app/features/shell/main_scaffold.dart';
// --- ADD THESE 2 NEW IMPORTS ---
import 'package:rms_tenant_app/features/agreement/presentation/agreement_screen.dart';
import 'package:rms_tenant_app/features/smart_home/presentation/smart_home_screen.dart';
import 'package:rms_tenant_app/features/notifications/presentation/notification_screen.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart'; // <-- 1. IMPORT MODEL
import 'package:rms_tenant_app/features/invoices/presentation/invoice_detail_screen.dart'; // <-- 2. IMPORT DETAIL SCREEN


// --- Create a GlobalKey for the shell ---
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',

    routes: [
      // --- Routes for users NOT logged in ---
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),

      // --- Routes for users WHO ARE logged in (The Shell) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        
        // --- UPDATED 4-BRANCH LAYOUT ---
        branches: [
          // Branch 0: Home (and Profile)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey, 
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // Profile is now a sub-route of Home
                  GoRoute(
                    path: 'profile', // Path will be '/profile'
                    builder: (context, state) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'notifications', // Path will be '/notifications'
                    builder: (context, state) => const NotificationScreen(),
                  ),
                ]
              ),
            ],
          ),
          
          // Branch 1: Agreement
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agreement',
                builder: (context, state) => const AgreementScreen(),
              ),
            ],
          ),
          
          // Branch 2: Smart Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/smart-home',
                builder: (context, state) => const SmartHomeScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoices',
                builder: (context, state) => const InvoicesScreen(),
                
                // --- 2. ADD THIS SUB-ROUTE ---
                routes: [
                  GoRoute(
                    path: 'detail', // Full path will be /invoices/detail
                    builder: (context, state) {
                      // Get the Invoice object we pass to it
                      final invoice = state.extra as Invoice;
                      return InvoiceDetailScreen(invoice: invoice);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // --- Redirect Logic ---
    redirect: (context, state) {
      final status = authState.asData?.value;
      final isAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (status == AuthStatus.signedOut && !isAuthPage) {
        return '/login';
      }
      if (status == AuthStatus.signedIn && isAuthPage) {
        return '/'; // Go to the home screen
      }
      return null;
    },
  );
});