// This model now matches your detailed API response
class Tenancy {
  final int id;
  final String code;
  final String status;
  final double rentalFee;
  final String tenancyPeriodEndDate;
  final double houseDeposit;
  final double utilityDeposit;
  final double keyDeposit;
  final String fullPropertyName; // "Skyview Residence / B-19-20 / Room: room3"
  final Agreement agreement;

  // We can add more fields as needed
  
  Tenancy({
    required this.id,
    required this.code,
    required this.status,
    required this.rentalFee,
    required this.tenancyPeriodEndDate,
    required this.houseDeposit,
    required this.utilityDeposit,
    required this.keyDeposit,
    required this.fullPropertyName,
    required this.agreement,
  });

  // Factory constructor to create a Tenancy from JSON
  factory Tenancy.fromJson(Map<String, dynamic> json) {
    return Tenancy(
      id: json['id'],
      code: json['code'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      rentalFee: double.tryParse(json['rental_fee'].toString()) ?? 0.0,
      tenancyPeriodEndDate: json['tenancy_period_end_date'] ?? 'N/A',
      houseDeposit: double.tryParse(json['house_deposit'].toString()) ?? 0.0,
      utilityDeposit: double.tryParse(json['utility_deposit'].toString()) ?? 0.0,
      keyDeposit: double.tryParse(json['key_deposit'].toString()) ?? 0.0,
      fullPropertyName: json['full_property_name'] ?? 'N/A',
      agreement: Agreement.fromJson(json['agreement'] ?? {}),
    );
  }
}

// A new class to hold the nested agreement details
class Agreement {
  final int id;
  final String landlordName;
  final String tenantName;
  final String startDate;
  final String endDate;
  final double rentalAmount;
  final String paymentDueDay;
  final List<String> attachmentUrls;

  Agreement({
    required this.id,
    required this.landlordName,
    required this.tenantName,
    required this.startDate,
    required this.endDate,
    required this.rentalAmount,
    required this.paymentDueDay,
    required this.attachmentUrls,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] ?? 0,
      landlordName: json['landlord_name'] ?? 'N/A',
      tenantName: json['tenant_name'] ?? 'N/A',
      startDate: json['start_date'] ?? 'N/A',
      endDate: json['end_date'] ?? 'N/A',
      rentalAmount: double.tryParse(json['rental_amount'].toString()) ?? 0.0,
      paymentDueDay: json['payment_due_day'] ?? 'N/A',
      attachmentUrls: List<String>.from(json['attachment_urls'] ?? []),
    );
  }
}