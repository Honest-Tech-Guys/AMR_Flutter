import 'package:flutter/material.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({required this.invoice, super.key});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);
    final statusColor = _getStatusColor(invoice.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Header Card ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM ${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Summary Card ---
          _buildDetailCard(
            title: 'Summary',
            children: [
              _buildDetailRow('Invoice Number', invoice.invoiceNumber),
              _buildDetailRow('Issue Date', invoice.issueDate),
              _buildDetailRow('Due Date', invoice.dueDate),
              if (invoice.notes.isNotEmpty)
                _buildDetailRow('Notes', invoice.notes),
            ],
          ),
          const SizedBox(height: 16),

          // --- Items Card ---
          _buildDetailCard(
            title: 'Items',
            children: [
              // Items Header
              const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Qty x Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  final itemTotal = item.quantity * item.unitPrice * (1 + item.taxPercentage / 100);
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.itemName),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.quantity.toStringAsFixed(0)} x ${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          itemTotal.toStringAsFixed(2),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
              const Divider(height: 20),
              // Totals
              _buildTotalRow('Subtotal', invoice.subTotal),
              _buildTotalRow('Tax', invoice.totalTax),
              _buildTotalRow('Total Amount', invoice.totalAmount, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDetailCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotalRow(String title, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            'RM ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
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