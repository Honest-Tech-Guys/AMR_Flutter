import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/features/notifications/notification_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';
import 'package:rms_tenant_app/features/invoices/invoices_provider.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';
import 'package:rms_tenant_app/features/smart_home/smart_home_provider.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const route = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasShownAuthError = false;

  // Pull-to-refresh handler
  Future<void> _handleRefresh() async {
    ref.invalidate(homeTenancyProvider);
    ref.invalidate(invoicesProvider);
    ref.invalidate(notificationProvider);
    ref.invalidate(smartDevicesProvider);

    try {
      await ref.read(homeTenancyProvider.future);
    } catch (e) {
      print('Refresh error caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    const Color primaryColor = Color(0xFF076633);

    // Listen to auth state changes for auto-redirect
    ref.listen(authControllerProvider, (previous, next) {
      if (next.value == AuthStatus.signedOut) {
        print('Auth state changed to signed out - router will redirect');
      }
    });

    // If signed out, show a brief message (router will redirect)
    if (authState.value == AuthStatus.signedOut) {
      return Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to login...'),
            ],
          ),
        ),
      );
    }

    final tenancyAsyncValue = ref.watch(homeTenancyProvider);

    return tenancyAsyncValue.when(
      data: (tenancy) {
        _hasShownAuthError = false; // Reset flag on success

        // --- HANDLE NULL TENANCY (No Active Tenancy) ---
        if (tenancy == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              titleSpacing: 16,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            backgroundColor: Colors.grey[100],
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 150,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Active Tenancy',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You don\'t have an active tenancy at the moment.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // --- NORMAL FLOW: Tenancy exists ---
        final String tenantName = tenancy.agreement.tenantName;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Welcome, $tenantName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            titleSpacing: 16,
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final notificationAsync = ref.watch(notificationProvider);
                  final unreadCount =
                      notificationAsync.asData?.value.unreadCount ?? 0;

                  return Badge(
                    label: Text('$unreadCount'),
                    isLabelVisible: unreadCount > 0,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.black, size: 28),
                      onPressed: () {
                        context.go('/notifications');
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMyUnitCard(context, tenancy),
                    const SizedBox(height: 24),
                    _buildQuickAccess(context),
                    const SizedBox(height: 24),
                    _buildLatestInvoices(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },

      error: (error, stackTrace) {
        // Check for authentication errors
        final isAuthError = error.toString().contains('Authentication') ||
            error.toString().contains('authenticated') ||
            error.toString().contains('401') ||
            error.toString().contains('Redirecting');

        // Auto-logout on auth error (only once to prevent loops)
        if (isAuthError && !_hasShownAuthError) {
          _hasShownAuthError = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('Auth error detected - triggering auto-logout');
              ref.read(authControllerProvider.notifier).logout();
            }
          });
        }

        // Show error screen
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAuthError ? Icons.lock_outline : Icons.error_outline,
                    size: 64,
                    color: isAuthError ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAuthError
                        ? 'Authentication Error'
                        : 'Could not load home screen',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAuthError
                        ? 'Your session has expired. Redirecting to login...'
                        : error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (isAuthError)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        ref.invalidate(homeTenancyProvider);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },

      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Loading...', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 1,
          ),
          body: const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }

  // All helper widgets remain the same...
  Widget _buildMyUnitCard(BuildContext context, Tenancy tenancy) {
    const Color primaryColor = Color(0xFF076633);
    final DateTime endDate = DateTime.tryParse(tenancy.agreement.endDate) ?? DateTime.now();
    final DateTime today = DateTime.now();
    final int remainingDays = endDate.difference(today).inDays;
    final String startDateFormatted = _formatDate(tenancy.agreement.startDate);
    final String endDateFormatted = _formatDate(tenancy.agreement.endDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tenancy Period', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text('$startDateFormatted – $endDateFormatted',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => context.go('/agreement'),
                child: const Text('View Details', style: TextStyle(color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRentalFeeSection(context, tenancy, primaryColor),
                      const SizedBox(height: 16),
                      _buildTenancyRemainingSection(remainingDays, primaryColor),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRentalFeeSection(context, tenancy, primaryColor)),
                    const SizedBox(width: 16),
                    _buildTenancyRemainingSection(remainingDays, primaryColor),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalFeeSection(BuildContext context, Tenancy tenancy, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Rental Fee', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text('RM ${tenancy.rentalFee.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auto Debit setup coming soon!')),
              );
            },
            child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Set up Auto Debit')),
          ),
        ),
      ],
    );
  }

  Widget _buildTenancyRemainingSection(int remainingDays, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tenancy Remaining', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text('$remainingDays Days',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF076633))),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text('Quick Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = 110.0;
            final spacing = 16.0;
            final availableWidth = constraints.maxWidth;
            final itemsPerRow = (availableWidth + spacing) ~/ (itemWidth + spacing);

            final smartLockTile = Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final smartDeviceAsync = ref.watch(smartDevicesProvider);
                  return _buildQuickAccessTile(context, 'Smart Lock', Icons.lock_outline, '/smart-home',
                    onTap: () {
                      smartDeviceAsync.when(
                        data: (data) {
                          final firstLock = data.locks.isNotEmpty ? data.locks.first : null;
                          if (firstLock != null) {
                            context.go('/smart-home/detail', extra: firstLock);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No smart lock found!')),
                            );
                          }
                        },
                        error: (e, s) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not load smart lock: $e')),
                        ),
                        loading: () {},
                      );
                    },
                  );
                },
              ),
            );

            if (itemsPerRow >= 3) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildQuickAccessTile(context, 'Agreement', Icons.description_outlined, '/agreement')),
                  const SizedBox(width: 16),
                  smartLockTile,
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuickAccessTile(context, 'History', Icons.history, '/history')),
                ],
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAccessTile(context, 'Agreement', Icons.description_outlined, '/agreement'),
                  const SizedBox(width: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final smartDeviceAsync = ref.watch(smartDevicesProvider);
                      return _buildQuickAccessTile(context, 'Smart Lock', Icons.lock_outline, '/smart-home',
                        onTap: () {
                          smartDeviceAsync.when(
                            data: (data) {
                              final firstLock = data.locks.isNotEmpty ? data.locks.first : null;
                              if (firstLock != null) {
                                context.go('/smart-home/detail', extra: firstLock);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No smart lock found!')),
                                );
                              }
                            },
                            error: (e, s) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not load smart lock: $e')),
                            ),
                            loading: () {},
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAccessTile(context, 'History', Icons.history, '/history'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessTile(BuildContext context, String title, IconData icon, String route, {VoidCallback? onTap}) {
    const Color primaryColor = Color(0xFF076633);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 140),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: InkWell(
            onTap: onTap ?? () {
              if (route == '/agreement' || route == '/smart-home') {
                context.go(route);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title feature coming soon!')),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestInvoices(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);
    return Consumer(
      builder: (context, ref, child) {
        final invoicesAsyncValue = ref.watch(invoicesProvider);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Latest Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => context.go('/invoices'),
                      child: const Text('See all', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                invoicesAsyncValue.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading invoices: $err'),
                  ),
                  data: (invoices) {
                    if (invoices.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No invoices found.'),
                      );
                    }
                    final latestInvoices = invoices.take(3).toList();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestInvoices.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) => _buildInvoiceRow(context: context, invoice: latestInvoices[index]),
                      separatorBuilder: (context, index) => const Divider(height: 1),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceRow({required BuildContext context, required Invoice invoice}) {
    final String statusText;
    final Color statusColor;
    final IconData iconData;

    if (invoice.isOverdue) {
      statusText = 'Overdue';
      statusColor = Colors.red;
      iconData = Icons.error_outline;
    } else {
      statusText = invoice.status;
      statusColor = _getStatusColor(invoice.status);
      iconData = Icons.receipt;
    }

    final title = invoice.items.isNotEmpty ? invoice.items.first.itemName : 'Invoice';

    return InkWell(
      onTap: () => context.go('/invoices/detail', extra: invoice),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(iconData, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return Colors.green;
      case 'sent': return Colors.blue;
      case 'due': return Colors.orange;
      default: return Colors.grey;
    }
  }
}