import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';
// import 'package:url_launcher/url_launcher.dart'; // We'll add this later

class AgreementScreen extends ConsumerWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We re-use the same provider from the Home screen.
    // Riverpod caches the data, so this is instant and costs no extra API calls.
    final tenancyAsyncValue = ref.watch(homeTenancyProvider);
    const Color primaryColor = Color(0xFF076633);

    return DefaultTabController(
      length: 3, // We have 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agreement'),
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: const TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: 'Agreement Details'),
              Tab(text: 'Tenancy Details'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: tenancyAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (tenancy) {
            // Once data is loaded, show the TabBarView
            return TabBarView(
              children: [
                _buildAgreementDetailsTab(tenancy),
                _buildTenancyDetailsTab(tenancy),
                _buildDocumentsTab(tenancy),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Tab 1: Agreement Details ---
  Widget _buildAgreementDetailsTab(Tenancy tenancy) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDetailCard([
          _buildDetailRow('Agreement Code', tenancy.code),
          _buildDetailRow('Landlord Name', tenancy.agreement.landlordName),
          _buildDetailRow('Tenant Name', tenancy.agreement.tenantName),
          _buildDetailRow('Start Date', tenancy.agreement.startDate),
          _buildDetailRow('End Date', tenancy.agreement.endDate),
          _buildDetailRow(
            'Payment Due Day',
            'Every ${tenancy.agreement.paymentDueDay}th of the month',
          ),
          _buildDetailRow(
            'Rental Amount',
            'RM ${tenancy.agreement.rentalAmount.toStringAsFixed(2)}',
          ),
        ]),
      ],
    );
  }

  // --- Tab 2: Tenancy Details ---
  Widget _buildTenancyDetailsTab(Tenancy tenancy) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDetailCard([
          _buildDetailRow('Unit Name', tenancy.fullPropertyName),
          _buildDetailRow(
            'Rental Fee',
            'RM ${tenancy.rentalFee.toStringAsFixed(2)}',
          ),
          _buildDetailRow('Status', tenancy.status),
          _buildDetailRow(
            'House Deposit',
            'RM ${tenancy.houseDeposit.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Utility Deposit',
            'RM ${tenancy.utilityDeposit.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Key Deposit',
            'RM ${tenancy.keyDeposit.toStringAsFixed(2)}',
          ),
        ]),
      ],
    );
  }

  // --- Tab 3: Documents ---
  Widget _buildDocumentsTab(Tenancy tenancy) {
    final documents = tenancy.agreement.attachmentUrls;

    if (documents.isEmpty) {
      return const Center(
        child: Text('No documents found.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final url = documents[index];
        // Get the last part of the URL as the filename
        final fileName = url.split('/').last; 
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(fileName),
            subtitle: const Text('Tap to view'),
            trailing: const Icon(Icons.download_for_offline_outlined),
            onTap: () {
              // TODO: Add url_launcher package to open this link
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Will open: $fileName')),
              );
            },
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---
  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}