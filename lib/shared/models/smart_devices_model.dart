// This model represents the 'data' object in your response
class SmartDeviceResponse {
  final String tenancyCode;
  final List<SmartMeter> meters;
  final List<SmartLock> locks;

  SmartDeviceResponse({
    required this.tenancyCode,
    required this.meters,
    required this.locks,
  });

  factory SmartDeviceResponse.fromJson(Map<String, dynamic> json) {
    // Get the nested lists
    final List<dynamic> meterList = json['data']?['meters'] ?? [];
    final List<dynamic> lockList = json['data']?['locks'] ?? [];

    return SmartDeviceResponse(
      tenancyCode: json['data']?['tenancy_code'] ?? 'N/A',
      meters: meterList.map((m) => SmartMeter.fromJson(m)).toList(),
      locks: lockList.map((l) => SmartLock.fromJson(l)).toList(),
    );
  }
}

// Model for a single SmartMeter
class SmartMeter {
  final int id;
  final String name;
  final double balanceUnit;
  final String connectionStatus;
  final String powerStatus;
  final double unitPrice;
  final int minimumTopupUnit; // <-- THIS FIELD IS NEW

  SmartMeter({
    required this.id,
    required this.name,
    required this.balanceUnit,
    required this.connectionStatus,
    required this.powerStatus,
    required this.unitPrice,
    required this.minimumTopupUnit, // <-- ADDED
  });

  factory SmartMeter.fromJson(Map<String, dynamic> json) {
    return SmartMeter(
      id: json['id'],
      name: json['name'] ?? 'Smart Meter',
      balanceUnit: double.tryParse(json['balance_unit'].toString()) ?? 0.0,
      connectionStatus: json['connection_status'] ?? 'unknown',
      powerStatus: json['power_status'] ?? 'unknown',
      unitPrice: double.tryParse(json['unit_price_per_unit'].toString()) ?? 0.0,
      minimumTopupUnit: json['minimum_topup_unit'] ?? 10, // <-- ADDED
    );
  }
}

// Model for a single SmartLock
class SmartLock {
  final int id;
  final String serialNumber;

  SmartLock({
    required this.id,
    required this.serialNumber,
  });

  factory SmartLock.fromJson(Map<String, dynamic> json) {
    return SmartLock(
      id: json['id'],
      serialNumber: json['serial_number'] ?? 'N/A',
    );
  }
}