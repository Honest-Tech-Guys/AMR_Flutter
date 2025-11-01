import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';
// 1. IMPORT THE PDF VIEWER PACKAGE
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AgreementScreen extends ConsumerWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

  // --- Tab 1: Agreement Details (No change) ---
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

  // --- Tab 2: Tenancy Details (No change) ---
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
        ]),
      ],
    );
  }

  // --- UPDATED DOCUMENTS TAB ---
  Widget _buildDocumentsTab(Tenancy tenancy) {
    final documents = tenancy.agreement.attachmentUrls;

    if (documents.isEmpty) {
      return const Center(
        child: Text('No documents found.'),
      );
    }
    
    // Get the first PDF URL from the list
    final String pdfUrl = documents.first;

    // Use the PDF Viewer widget
    return SfPdfViewer.network(
      pdfUrl,
      // The loading indicator is shown by default.
      // The incorrect line 'canShowLoadingIndicator: true' has been removed.
    );
  }

  // --- Helper Widgets (No change) ---
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
  
  // --- UPDATED Helper Widget for Detail Rows ---
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 16), // Add spacing
          
          // Value (now wrapped in Expanded to allow wrapping)
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right, // Align to the right
            ),
          ),
        ],
      ),
    );
  }
}