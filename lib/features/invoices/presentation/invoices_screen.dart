import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT ROUTER
import 'package:rms_tenant_app/features/invoices/invoices_provider.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsyncValue = ref.watch(invoicesProvider);
    const Color primaryColor = Color(0xFF076633);

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
          child: Text('Error: $err'),
        ),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(
              child: Text('No invoices found.'),
            );
          }
          
          // Build a list of all invoices
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return _buildInvoiceCard(context, invoice); // <-- Pass context
            },
          );
        },
      ),
    );
  }

  // A helper to build a card for the Invoices list
  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);
    
    // Get the first item name, or a fallback
    final title = invoice.items.isNotEmpty ? invoice.items.first.itemName : 'Invoice';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      // --- WRAP WITH INKWELL ---
      child: InkWell(
        onTap: () {
          // Navigate to the detail screen, passing the invoice object
          context.go('/invoices/detail', extra: invoice);
        },
        borderRadius: BorderRadius.circular(12),
        // -------------------------
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'RM ${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF076633),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title, // Use the parsed item name
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Due Date', invoice.dueDate),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

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