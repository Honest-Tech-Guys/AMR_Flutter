import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/presentation/login_screen.dart';
import 'package:rms_tenant_app/features/auth/presentation/registration_screen.dart';
import 'package:rms_tenant_app/features/auth/presentation/verification_screen.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_screen/home_screen.dart';
import 'package:rms_tenant_app/features/invoices/presentation/invoices_screen.dart';
import 'package:rms_tenant_app/features/profile/presentation/profile_screen.dart';
import 'package:rms_tenant_app/features/shell/main_scaffold.dart';
import 'package:rms_tenant_app/features/agreement/presentation/agreement_screen.dart';
import 'package:rms_tenant_app/features/smart_home/presentation/smart_home_screen.dart';
import 'package:rms_tenant_app/features/notifications/presentation/notification_screen.dart';
import 'package:rms_tenant_app/features/invoices/presentation/invoice_detail_screen.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';
import 'package:rms_tenant_app/features/smart_home/presentation/smart_lock_detail_screen.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';
import 'package:rms_tenant_app/features/smart_home/presentation/add_smart_lock_screen.dart';

// --- 1. IMPORT THE NEW SCREEN ---
import 'package:rms_tenant_app/features/auth/presentation/not_tenant_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',

    // No refreshListenable needed, as 'authState' is watched.

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => const VerificationScreen(),
      ),

      // --- 2. ADD THE NEW NOT-TENANT ROUTE ---
      GoRoute(
        path: NotTenantScreen.route, // This is '/not-tenant'
        builder: (context, state) => const NotTenantScreen(),
      ),

      // --- Main App Shell (Unchanged) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                  routes: [
                    GoRoute(
                      path: 'profile',
                      builder: (context, state) => const ProfileScreen(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      builder: (context, state) => const NotificationScreen(),
                    ),
                  ]),
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
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final lock = state.extra as SmartLock;
                      return SmartLockDetailScreen(lock: lock);
                    },
                  ),
                  // Add this new route
                  GoRoute(
                    path: 'add-lock',
                    builder: (context, state) => const AddSmartLockScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Invoices
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoices',
                builder: (context, state) => const InvoicesScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
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

    // --- 3. UPDATED REDIRECT LOGIC ---
    redirect: (context, state) {
      final status = authState.asData?.value;

      final isAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isVerifyPage = state.matchedLocation == '/verify';
      // --- ADDED ---
      final isNotTenantPage = state.matchedLocation == NotTenantScreen.route;

      // While loading, don't redirect
      if (authState.isLoading || status == null) {
        return null;
      }

      // 1. User is logged out
      if (status == AuthStatus.signedOut) {
        // If on login/register, stay. Otherwise, redirect to login.
        return isAuthPage ? null : '/login';
      }

      // --- ADDED ---
      // 2. User is Not a Tenant
      if (status == AuthStatus.notTenant) {
        // If on the not-tenant page, stay. Otherwise, redirect to it.
        return isNotTenantPage ? null : NotTenantScreen.route;
      }
      // --- END ADDED ---

      // 3. User needs verification
      if (status == AuthStatus.needsVerification) {
        // If on verify page, stay. Otherwise, redirect to it.
        return isVerifyPage ? null : '/verify';
      }

      // 4. User is signed in (and verified and tenant)
      if (status == AuthStatus.signedIn) {
        // --- MODIFIED ---
        // If on *any* auth-related page, redirect to home ('/').
        final isAnyAuthFlowPage = isAuthPage || isVerifyPage || isNotTenantPage;
        return isAnyAuthFlowPage ? '/' : null;
      }

      return null;
    },
  );
});