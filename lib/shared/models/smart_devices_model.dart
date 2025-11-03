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
  final int minimumTopupUnit;

  SmartMeter({
    required this.id,
    required this.name,
    required this.balanceUnit,
    required this.connectionStatus,
    required this.powerStatus,
    required this.unitPrice,
    required this.minimumTopupUnit,
  });

  factory SmartMeter.fromJson(Map<String, dynamic> json) {
    return SmartMeter(
      id: json['id'],
      name: json['name'] ?? 'Smart Meter',
      balanceUnit: double.tryParse(json['balance_unit'].toString()) ?? 0.0,
      connectionStatus: json['connection_status'] ?? 'unknown',
      powerStatus: json['power_status'] ?? 'unknown',
      unitPrice: double.tryParse(json['unit_price_per_unit'].toString()) ?? 0.0,
      minimumTopupUnit: json['minimum_topup_unit'] ?? 10,
    );
  }
}

// UPDATED Model for a single SmartLock
class SmartLock {
  final int id;
  final String serialNumber;
  final String? lockData;        // NEW: TTLock SDK data
  final String? lockMac;         // NEW: Bluetooth MAC address
  final String? lockName;        // NEW: Display name
  final int? electricQuantity;   // NEW: Battery level

  SmartLock({
    required this.id,
    required this.serialNumber,
    this.lockData,
    this.lockMac,
    this.lockName,
    this.electricQuantity,
  });

  factory SmartLock.fromJson(Map<String, dynamic> json) {
    return SmartLock(
      id: json['id'],
      serialNumber: json['serial_number'] ?? 'N/A',
      lockData: json['lock_data'],              // NEW
      lockMac: json['lock_mac'],                // NEW
      lockName: json['lock_name'],              // NEW
      electricQuantity: json['electric_quantity'], // NEW
    );
  }
}