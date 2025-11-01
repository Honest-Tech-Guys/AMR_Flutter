// A new class for the nested items in an invoice
class InvoiceItem {
  final int id;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double taxPercentage;

  InvoiceItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.taxPercentage,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      itemName: json['item_name'] ?? 'N/A',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
      taxPercentage: double.tryParse(json['tax_percentage'].toString()) ?? 0.0,
    );
  }
}

// The updated Invoice model
class Invoice {
  final int id;
  final String invoiceNumber;
  final String issueDate;
  final String dueDate;
  final double subTotal;
  final double totalTax;
  final double totalAmount;
  final String status;
  final String notes;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.subTotal,
    required this.totalTax,
    required this.totalAmount,
    required this.status,
    required this.notes,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Parse the list of items
    final List<dynamic> itemsList = json['items'] ?? [];
    final List<InvoiceItem> parsedItems =
        itemsList.map((itemJson) => InvoiceItem.fromJson(itemJson)).toList();

    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'] ?? 'N/A',
      issueDate: json['issue_date'] ?? 'N/A',
      dueDate: json['due_date'] ?? 'N/A',
      subTotal: double.tryParse(json['sub_total'].toString()) ?? 0.0,
      totalTax: double.tryParse(json['total_tax'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'Unknown',
      notes: json['notes'] ?? '',
      items: parsedItems,
    );
  }
}