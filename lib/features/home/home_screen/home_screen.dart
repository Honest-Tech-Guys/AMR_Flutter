import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/features/notifications/notification_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';
import 'package:rms_tenant_app/features/invoices/invoices_provider.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasShownAuthError = false;

  @override
  Widget build(BuildContext context) {
    // Watch auth state to catch logout
    final authState = ref.watch(authControllerProvider);
    
    // Listen to auth state changes for auto-redirect
    ref.listen(authControllerProvider, (previous, next) {
      // If auth state changes to signed out, router will handle redirect
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
    const Color primaryColor = Color(0xFF076633);

    return tenancyAsyncValue.when(
      data: (tenancy) {
        _hasShownAuthError = false; // Reset flag on success
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
            child: SingleChildScrollView(
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
        );
      },
      
      error: (error, stackTrace) {
        // Check if it's an auth error
        final isAuthError = error.toString().contains('Authentication') || 
                           error.toString().contains('authenticated') ||
                           error.toString().contains('401') ||
                           error.toString().contains('Redirecting');
        
        // Auto-logout on auth error (only once to prevent loops)
        if (isAuthError && !_hasShownAuthError) {
          _hasShownAuthError = true;
          
          // Schedule logout after this frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('Auth error detected - triggering auto-logout');
              ref.read(authControllerProvider.notifier).logout();
            }
          });
        }
        
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
                        // Invalidate the provider to retry
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
                Text(
                  'Tenancy Period',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$startDateFormatted – $endDateFormatted',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  context.go('/agreement');
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.black87),
                ),
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
                    Expanded(
                      child: _buildRentalFeeSection(context, tenancy, primaryColor),
                    ),
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
        Text(
          'Rental Fee',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'RM ${tenancy.rentalFee.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auto Debit setup coming soon!')),
              );
            },
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Set up Auto Debit'),
            ),
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
        Text(
          'Tenancy Remaining',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$remainingDays Days',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF076633),
          ),
        ),
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
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = 110.0;
            final spacing = 16.0;
            final availableWidth = constraints.maxWidth;
            final itemsPerRow = (availableWidth + spacing) ~/ (itemWidth + spacing);
            
            if (itemsPerRow >= 3) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildQuickAccessTile(
                      context,
                      'Agreement',
                      Icons.description_outlined,
                      '/agreement',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccessTile(
                      context,
                      'Smart Lock',
                      Icons.lock_outline,
                      '/smart-home',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccessTile(
                      context,
                      'History',
                      Icons.history,
                      '/history',
                    ),
                  ),
                ],
              );
            }
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAccessTile(
                    context,
                    'Agreement',
                    Icons.description_outlined,
                    '/agreement',
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAccessTile(
                    context,
                    'Smart Lock',
                    Icons.lock_outline,
                    '/smart-home',
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAccessTile(
                    context,
                    'History',
                    Icons.history,
                    '/history',
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessTile(BuildContext context, String title, IconData icon, String route) {
    const Color primaryColor = Color(0xFF076633);
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 140,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: InkWell(
            onTap: () {
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
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATED WIDGET FOR LATEST INVOICES ---
  // --- UPDATED WIDGET FOR LATEST INVOICES ---
  Widget _buildLatestInvoices(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);
    
    // We will watch the invoices provider here
    return Consumer(
      builder: (context, ref, child) {
        final invoicesAsyncValue = ref.watch(invoicesProvider);
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Title and "See all" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Invoices',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/invoices'); // Navigate to Invoices screen
                      },
                      child: const Text('See all', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Use the provider's state
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
                    
                    // Get just the first 3
                    final latestInvoices = invoices.take(3).toList();
                    
                    // Build the list
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = latestInvoices[index];
                        // --- PASS CONTEXT AND INVOICE ---
                        return _buildInvoiceRow(
                          context: context, 
                          invoice: invoice,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
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

  // --- UPDATED Helper for a single invoice row (now tappable) ---
  Widget _buildInvoiceRow({required BuildContext context, required Invoice invoice}) {
    final statusColor = _getStatusColor(invoice.status);
    final title = invoice.items.isNotEmpty ? invoice.items.first.itemName : 'Invoice';

    return InkWell(
      onTap: () {
        // --- ADD NAVIGATION ---
        context.go('/invoices/detail', extra: invoice);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.receipt, color: Colors.grey),
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
              child: Text(
                invoice.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ADD this helper to home_screen.dart as well ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'due':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}