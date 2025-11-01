import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/features/notifications/notification_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenancyAsyncValue = ref.watch(homeTenancyProvider);
    const Color primaryColor = Color(0xFF076633);

    return tenancyAsyncValue.when(
      data: (tenancy) {
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
                  const SizedBox(height: 24), // Extra bottom padding
                ],
              ),
            ),
          ),
        );
      },
      
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Could not load home screen. Make sure you are logged in as a TENANT.\n\nError: $error',
                textAlign: TextAlign.center,
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
            // Top Section - Tenancy Period
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
            
            // View Details Button (Full Width)
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
            
            // Bottom Section - Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                // If screen is narrow, stack vertically
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
                // Otherwise use row layout
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
        // Responsive Grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate how many items can fit
            final itemWidth = 110.0;
            final spacing = 16.0;
            final availableWidth = constraints.maxWidth;
            final itemsPerRow = (availableWidth + spacing) ~/ (itemWidth + spacing);
            
            // If all items fit, use Row with equal spacing
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
            
            // Otherwise use horizontal scroll
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

  Widget _buildLatestInvoices(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Invoices',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/invoices');
                  },
                  child: const Text('See all', style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInvoiceRow('INV-2024-001', 'Oct 2024 Rent', 'Paid', Colors.green),
            const Divider(),
            _buildInvoiceRow('INV-2024-002', 'Sep 2024 Rent', 'Paid', Colors.green),
            const Divider(),
            _buildInvoiceRow('INV-2024-003', 'Aug 2024 Rent', 'Paid', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String invNumber, String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.receipt, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}