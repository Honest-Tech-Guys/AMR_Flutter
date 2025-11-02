import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/invoices/invoices_provider.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color primaryColor = Color(0xFF076633);
    final invoicesAsyncValue = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: invoicesAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading invoices: $err'),
          ),
        ),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices found.'));
          }

          // 1. SEPARATE LISTS using the new getter
          final overdueInvoices = invoices.where((inv) => inv.isOverdue).toList();
          final otherInvoices = invoices.where((inv) => !inv.isOverdue).toList();

          // 2. BUILD A LISTVIEW WITH SECTIONS
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- OVERDUE SECTION (if any) ---
              if (overdueInvoices.isNotEmpty)
                ..._buildInvoiceSection(
                  context: context,
                  title: 'Overdue',
                  invoices: overdueInvoices,
                  isOverdueSection: true, // Pass flag for styling
                ),

              // --- OTHER INVOICES SECTION ---
              if (otherInvoices.isNotEmpty)
                ..._buildInvoiceSection(
                  context: context,
                  title: 'All Invoices',
                  invoices: otherInvoices,
                ),
            ],
          );
        },
      ),
    );
  }

  // 3. HELPER TO BUILD A SECTION (Title + List)
  List<Widget> _buildInvoiceSection({
    required BuildContext context,
    required String title,
    required List<Invoice> invoices,
    bool isOverdueSection = false,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isOverdueSection ? Colors.red : Colors.black,
          ),
        ),
      ),
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        // Use clipBehavior to make sure the InkWell ripples are clipped
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return _buildInvoiceRow(context: context, invoice: invoice);
          },
          separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
        ),
      ),
      const SizedBox(height: 16), // Space between sections
    ];
  }

  // 4. HELPER FOR A SINGLE INVOICE ROW
  Widget _buildInvoiceRow({required BuildContext context, required Invoice invoice}) {
    
    // 5. UPDATED STATUS LOGIC
    final String statusText;
    final Color statusColor;

    if (invoice.isOverdue) {
      statusText = 'Overdue';
      statusColor = Colors.red;
    } else {
      statusText = invoice.status;
      statusColor = _getOriginalStatusColor(invoice.status);
    }
    // --- END OF UPDATE ---
    
    final title = invoice.items.isNotEmpty ? invoice.items.first.itemName : 'Invoice';

    return InkWell(
      onTap: () {
        context.go('/invoices/detail', extra: invoice);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              // Show error icon if overdue
              invoice.isOverdue ? Icons.error_outline : Icons.receipt,
              color: invoice.isOverdue ? Colors.red : Colors.grey,
            ),
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
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Helper for original status colors
  Color _getOriginalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'due':
        return Colors.orange; // 'due' (but not overdue) can be orange
      default:
        return Colors.grey;
    }
  }
}