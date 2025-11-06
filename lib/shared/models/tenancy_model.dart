import 'package:rms_tenant_app/shared/models/equipment_model.dart';
import 'package:rms_tenant_app/shared/models/setting_model.dart';
// Complete Tenancy model matching the latest API response
class Tenancy {
  final int id;
  final String code;
  final String status;
  final double rentalFee;
  final String tenancyPeriodEndDate;
  final double houseDeposit;
  final double utilityDeposit;
  final double keyDeposit;
  final String fullPropertyName;
  final Agreement agreement;
  
  // Tenantable fields
  final int tenantId;
  final String tenantableType;
  final int tenantableId;
  
  // Additional tenancy fields
  final String dateOfAgreement;
  final String tenancyPeriodStartDate;
  final String rentalPaymentFrequency;
  final String remarks;
  final double electricityPricePerUnit;
  final double fitUpDeposit;
  final double restorationDeposit;
  final double otherDeposit;
  final String createdAt;
  final String updatedAt;
  final int createdBy;
  
  // Related objects
  final Tenant tenant;
  final Tenantable tenantable;
  final List<dynamic> documents;
  final List<dynamic> paymentSchedules;

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
    required this.tenantId,
    required this.tenantableType,
    required this.tenantableId,
    this.dateOfAgreement = 'N/A',
    this.tenancyPeriodStartDate = 'N/A',
    this.rentalPaymentFrequency = 'Monthly',
    this.remarks = '',
    this.electricityPricePerUnit = 0.0,
    this.fitUpDeposit = 0.0,
    this.restorationDeposit = 0.0,
    this.otherDeposit = 0.0,
    this.createdAt = '',
    this.updatedAt = '',
    this.createdBy = 0,
    required this.tenant,
    required this.tenantable,
    this.documents = const [],
    this.paymentSchedules = const [],
  });

  bool get isRoom => tenantableType.contains('Room');
  bool get isUnit => tenantableType.contains('Unit');

  factory Tenancy.fromJson(Map<String, dynamic> json) {
    return Tenancy(
      id: json['id'] ?? 0,
      code: json['code'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      rentalFee: double.tryParse(json['rental_fee']?.toString() ?? '0') ?? 0.0,
      tenancyPeriodEndDate: json['tenancy_period_end_date'] ?? 'N/A',
      houseDeposit: double.tryParse(json['house_deposit']?.toString() ?? '0') ?? 0.0,
      utilityDeposit: double.tryParse(json['utility_deposit']?.toString() ?? '0') ?? 0.0,
      keyDeposit: double.tryParse(json['key_deposit']?.toString() ?? '0') ?? 0.0,
      fullPropertyName: json['full_property_name'] ?? 'N/A',
      agreement: Agreement.fromJson(json['agreement'] ?? {}),
      tenantId: json['tenant_id'] ?? 0,
      tenantableType: json['tenantable_type'] ?? '',
      tenantableId: json['tenantable_id'] ?? 0,
      dateOfAgreement: json['date_of_agreement'] ?? 'N/A',
      tenancyPeriodStartDate: json['tenancy_period_start_date'] ?? 'N/A',
      rentalPaymentFrequency: json['rental_payment_frequency'] ?? 'Monthly',
      remarks: json['remarks'] ?? '',
      electricityPricePerUnit: double.tryParse(json['electricity_price_per_unit']?.toString() ?? '0') ?? 0.0,
      fitUpDeposit: double.tryParse(json['fit_up_deposit']?.toString() ?? '0') ?? 0.0,
      restorationDeposit: double.tryParse(json['restoration_deposit']?.toString() ?? '0') ?? 0.0,
      otherDeposit: double.tryParse(json['other_deposit']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by'] ?? 0,
      tenant: Tenant.fromJson(json['tenant'] ?? {}),
      tenantable: Tenantable.fromJson(json['tenantable'] ?? {}),
      documents: json['documents'] ?? [],
      paymentSchedules: json['payment_schedules'] ?? [],
    );
  }
}

class Tenant {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? emailVerifiedAt;
  final double balance;
  final String createdAt;
  final String updatedAt;
  final int? createdBy;
  final String? avatarUrl;
  final TenantProfile? tenantProfile;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.avatarUrl,
    this.tenantProfile,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      avatar: json['avatar'],
      emailVerifiedAt: json['email_verified_at'],
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by'],
      avatarUrl: json['avatar_url'],
      tenantProfile: json['tenant_profile'] != null 
          ? TenantProfile.fromJson(json['tenant_profile']) 
          : null,
    );
  }
}

class TenantProfile {
  final int id;
  final int userId;
  final String type;
  final String? altPhoneNumber;
  final String nationality;
  final String nricNumber;
  final String race;
  final String gender;
  final String addressLine1;
  final String city;
  final String postcode;
  final String state;
  final String country;
  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;
  final String? emergencyContactEmail;
  final String? remarks;

  TenantProfile({
    required this.id,
    required this.userId,
    required this.type,
    this.altPhoneNumber,
    required this.nationality,
    required this.nricNumber,
    required this.race,
    required this.gender,
    required this.addressLine1,
    required this.city,
    required this.postcode,
    required this.state,
    required this.country,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    this.emergencyContactEmail,
    this.remarks,
  });

  factory TenantProfile.fromJson(Map<String, dynamic> json) {
    return TenantProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? 'Individual',
      altPhoneNumber: json['alt_phone_number'],
      nationality: json['nationality'] ?? 'N/A',
      nricNumber: json['nric_number'] ?? 'N/A',
      race: json['race'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      addressLine1: json['address_line_1'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      postcode: json['postcode'] ?? 'N/A',
      state: json['state'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      emergencyContactName: json['emergency_contact_name'] ?? 'N/A',
      emergencyContactRelationship: json['emergency_contact_relationship'] ?? 'N/A',
      emergencyContactPhone: json['emergency_contact_phone'] ?? 'N/A',
      emergencyContactEmail: json['emergency_contact_email'],
      remarks: json['remarks'],
    );
  }
}

class Agreement {
  final int id;
  final int tenancyId;
  final String agreementDate;
  final String landlordName;
  final String? landlordPhone;
  final String? landlordEmail;
  final String? tenantSignature;
  final String? landlordIdentityNumber;
  final String? landlordAddress;
  final String tenantName;
  final String? tenantPhone;
  final String? tenantEmail;
  final String? tenantIdentityNumber;
  final String? tenantAddress;
  final String startDate;
  final String endDate;
  final double rentalAmount;
  final String paymentDueDay;
  final String? paymentBankName;
  final String? paymentBankHolderName;
  final String? paymentBankAccountNumber;
  final double securityDeposit;
  final double keyDeposit;
  final double advancedRentalAmount;
  final String? houseRulesRemarks;
  final String? termsConditionsRemarks;
  final String createdAt;
  final String updatedAt;
  final List<String> attachmentUrls;

  Agreement({
    required this.id,
    required this.tenancyId,
    required this.agreementDate,
    required this.landlordName,
    this.landlordPhone,
    this.landlordEmail,
    this.tenantSignature,
    this.landlordIdentityNumber,
    this.landlordAddress,
    required this.tenantName,
    this.tenantPhone,
    this.tenantEmail,
    this.tenantIdentityNumber,
    this.tenantAddress,
    required this.startDate,
    required this.endDate,
    required this.rentalAmount,
    required this.paymentDueDay,
    this.paymentBankName,
    this.paymentBankHolderName,
    this.paymentBankAccountNumber,
    required this.securityDeposit,
    required this.keyDeposit,
    required this.advancedRentalAmount,
    this.houseRulesRemarks,
    this.termsConditionsRemarks,
    required this.createdAt,
    required this.updatedAt,
    required this.attachmentUrls,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] ?? 0,
      tenancyId: json['tenancy_id'] ?? 0,
      agreementDate: json['agreement_date'] ?? 'N/A',
      landlordName: json['landlord_name'] ?? 'N/A',
      landlordPhone: json['landlord_phone'],
      landlordEmail: json['landlord_email'],
      landlordIdentityNumber: json['landlord_identity_number'],
      landlordAddress: json['landlord_address'],
      tenantName: json['tenant_name'] ?? 'N/A',
      tenantPhone: json['tenant_phone'],
      tenantEmail: json['tenant_email'],
      tenantIdentityNumber: json['tenant_identity_number'],
      tenantAddress: json['tenant_address'],
      startDate: json['start_date'] ?? 'N/A',
      endDate: json['end_date'] ?? 'N/A',
      rentalAmount: double.tryParse(json['rental_amount']?.toString() ?? '0') ?? 0.0,
      paymentDueDay: json['payment_due_day']?.toString() ?? 'N/A',
      paymentBankName: json['payment_bank_name'],
      paymentBankHolderName: json['payment_bank_holder_name'],
      paymentBankAccountNumber: json['payment_bank_account_number'],
      securityDeposit: double.tryParse(json['security_deposit']?.toString() ?? '0') ?? 0.0,
      keyDeposit: double.tryParse(json['key_deposit']?.toString() ?? '0') ?? 0.0,
      advancedRentalAmount: double.tryParse(json['advanced_rental_amount']?.toString() ?? '0') ?? 0.0,
      houseRulesRemarks: json['house_rules_remarks'],
      termsConditionsRemarks: json['terms_conditions_remarks'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      attachmentUrls: List<String>.from(json['attachment_urls'] ?? []),
      tenantSignature: json['tenant_signature'],
    );
  }
}

class Tenantable {
  final int id;
  final int unitId;
  final String name;
  final String status;
  final String? coordinates;
  final String description;
  final String? remarks;
  final String createdAt;
  final String updatedAt;
  final Unit unit;
  final List<Equipment> equipment;
  final Setting? setting;
  final List<Meter> meters;
  final List<Lock> locks;

  Tenantable({
    required this.id,
    required this.unitId,
    required this.name,
    required this.status,
    this.coordinates,
    required this.description,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.unit,
    this.meters = const [],
    this.locks = const [],
    required this.equipment,
    this.setting,
  });

  factory Tenantable.fromJson(Map<String, dynamic> json) {
    return Tenantable(
      id: json['id'] ?? 0,
      unitId: json['unit_id'] ?? 0,
      name: json['name'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      coordinates: json['coordinates'],
      description: json['description'] ?? '',
      remarks: json['remarks'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      unit: Unit.fromJson(json['unit'] ?? {}),
      meters: (json['meters'] as List?)?.map((m) => Meter.fromJson(m)).toList() ?? [],
      locks: (json['locks'] as List?)?.map((l) => Lock.fromJson(l)).toList() ?? [],
      equipment: (json['equipment'] as List?)
          ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      
      setting: json['setting'] != null
          ? Setting.fromJson(json['setting'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Meter {
  final int id;
  final String meterableType;
  final int meterableId;
  final String name;
  final String serialNumber;
  final String brand;
  final String model;
  final double usedUnit;
  final double balanceUnit;
  final String connectionStatus;
  final String powerStatus;
  final double unitPricePerUnit;
  final int minimumTopupUnit;
  final double minimumTopupRm;
  final int freeUnit;
  final String? freeUnitRefreshOn;
  final String? remarks;

  Meter({
    required this.id,
    required this.meterableType,
    required this.meterableId,
    required this.name,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.usedUnit,
    required this.balanceUnit,
    required this.connectionStatus,
    required this.powerStatus,
    required this.unitPricePerUnit,
    required this.minimumTopupUnit,
    required this.minimumTopupRm,
    required this.freeUnit,
    this.freeUnitRefreshOn,
    this.remarks,
  });

  factory Meter.fromJson(Map<String, dynamic> json) {
    return Meter(
      id: json['id'] ?? 0,
      meterableType: json['meterable_type'] ?? '',
      meterableId: json['meterable_id'] ?? 0,
      name: json['name'] ?? 'N/A',
      serialNumber: json['serial_number'] ?? 'N/A',
      brand: json['brand'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      usedUnit: double.tryParse(json['used_unit']?.toString() ?? '0') ?? 0.0,
      balanceUnit: double.tryParse(json['balance_unit']?.toString() ?? '0') ?? 0.0,
      connectionStatus: json['connection_status'] ?? 'unknown',
      powerStatus: json['power_status'] ?? 'unknown',
      unitPricePerUnit: double.tryParse(json['unit_price_per_unit']?.toString() ?? '0') ?? 0.0,
      minimumTopupUnit: json['minimum_topup_unit'] ?? 0,
      minimumTopupRm: double.tryParse(json['minimum_topup_rm']?.toString() ?? '0') ?? 0.0,
      freeUnit: json['free_unit'] ?? 0,
      freeUnitRefreshOn: json['free_unit_refresh_on'],
      remarks: json['remarks'],
    );
  }
}

class Lock {
  final int id;
  final String lockableType;
  final int lockableId;
  final String serialNumber;
  final String lockData;
  final String? lockMAC;
  final int autoCreatePasscode;
  final String? selfCheckOptions;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> assignments;

  Lock({
    required this.id,
    required this.lockableType,
    required this.lockableId,
    required this.serialNumber,
    required this.lockData,
    this.lockMAC,
    required this.autoCreatePasscode,
    this.selfCheckOptions,
    required this.createdAt,
    required this.updatedAt,
    this.assignments = const [],
  });

  factory Lock.fromJson(Map<String, dynamic> json) {
    return Lock(
      id: json['id'] ?? 0,
      lockableType: json['lockable_type'] ?? '',
      lockableId: json['lockable_id'] ?? 0,
      serialNumber: json['serial_number'] ?? 'N/A',
      lockData: json['lock_data'] ?? '',
      lockMAC: json['lock_MAC'],
      autoCreatePasscode: json['auto_create_passcode'] ?? 0,
      selfCheckOptions: json['self_check_options'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      assignments: json['assignments'] ?? [],
    );
  }
}

class Unit {
  final int id;
  final int propertyId;
  final int? beneficiaryId;
  final String block;
  final String floor;
  final String unitNumber;
  final String blockFloorUnitNumber;
  final String rentalType;
  final int bedroomCount;
  final int bathroomCount;
  final String? squareFeet;
  final String? unitImages;
  final String floorPlanImage;
  final String description;
  final String remarks;
  final String? accessCardNumbers;
  final String status;
  final int isActivated;
  final double serviceFeePercentage;
  final double profitSharingPercentage;
  final String createdAt;
  final String updatedAt;
  final String floorPlanImageUrl;
  final List<String> unitImagesUrls;
  final Property property;

  Unit({
    required this.id,
    required this.propertyId,
    this.beneficiaryId,
    required this.block,
    required this.floor,
    required this.unitNumber,
    required this.blockFloorUnitNumber,
    required this.rentalType,
    required this.bedroomCount,
    required this.bathroomCount,
    this.squareFeet,
    this.unitImages,
    required this.floorPlanImage,
    required this.description,
    required this.remarks,
    this.accessCardNumbers,
    required this.status,
    required this.isActivated,
    required this.serviceFeePercentage,
    required this.profitSharingPercentage,
    required this.createdAt,
    required this.updatedAt,
    required this.floorPlanImageUrl,
    required this.unitImagesUrls,
    required this.property,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      beneficiaryId: json['beneficiary_id'],
      block: json['block'] ?? '',
      floor: json['floor'] ?? '',
      unitNumber: json['unit_number'] ?? '',
      blockFloorUnitNumber: json['block_floor_unit_number'] ?? 'N/A',
      rentalType: json['rental_type'] ?? 'N/A',
      bedroomCount: json['bedroom_count'] ?? 0,
      bathroomCount: json['bathroom_count'] ?? 0,
      squareFeet: json['square_feet']?.toString(),
      unitImages: json['unit_images'],
      floorPlanImage: json['floor_plan_image'] ?? '',
      description: json['description'] ?? '',
      remarks: json['remarks'] ?? '',
      accessCardNumbers: json['access_card_numbers'],
      status: json['status'] ?? 'unknown',
      isActivated: json['is_activated'] ?? 0,
      serviceFeePercentage: double.tryParse(json['service_fee_percentage']?.toString() ?? '0') ?? 0.0,
      profitSharingPercentage: double.tryParse(json['profit_sharing_percentage']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      floorPlanImageUrl: json['floor_plan_image_url'] ?? '',
      unitImagesUrls: List<String>.from(json['unit_images_urls'] ?? []),
      property: Property.fromJson(json['property'] ?? {}),
    );
  }
}

class Property {
  final int id;
  final String propertyName;
  final String propertyType;
  final String status;
  final int ownerId;
  final int createdBy;
  final String contactName;
  final String contactPhone;
  final String remarks;
  final String addressLine1;
  final String city;
  final String postcode;
  final String state;
  final String country;
  final List<String> facilities;
  final String createdAt;
  final String updatedAt;
  final Owner owner;

  Property({
    required this.id,
    required this.propertyName,
    required this.propertyType,
    required this.status,
    required this.ownerId,
    required this.createdBy,
    required this.contactName,
    required this.contactPhone,
    required this.remarks,
    required this.addressLine1,
    required this.city,
    required this.postcode,
    required this.state,
    required this.country,
    required this.facilities,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? 0,
      propertyName: json['property_name'] ?? 'N/A',
      propertyType: json['property_type'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      ownerId: json['owner_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      contactName: json['contact_name'] ?? 'N/A',
      contactPhone: json['contact_phone'] ?? 'N/A',
      remarks: json['remarks'] ?? '',
      addressLine1: json['address_line_1'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      postcode: json['postcode'] ?? 'N/A',
      state: json['state'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      owner: Owner.fromJson(json['owner'] ?? {}),
    );
  }
}

class Owner {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? emailVerifiedAt;
  final double balance;
  final String createdAt;
  final String updatedAt;
  final int? createdBy;
  final String? avatarUrl;
  final OwnerProfile ownerProfile;

  Owner({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.avatarUrl,
    required this.ownerProfile,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      avatar: json['avatar'],
      emailVerifiedAt: json['email_verified_at'],
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by'],
      avatarUrl: json['avatar_url'],
      ownerProfile: OwnerProfile.fromJson(json['owner_profile'] ?? {}),
    );
  }
}

class OwnerProfile {
  final int id;
  final int userId;
  final String type;
  final String? altPhoneNumber;
  final String nationality;
  final String? nricNumber;
  final String? race;
  final String? gender;
  final String addressLine1;
  final String city;
  final String postcode;
  final String state;
  final String country;
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;
  final String? emergencyContactEmail;
  final String? remarks;

  OwnerProfile({
    required this.id,
    required this.userId,
    required this.type,
    this.altPhoneNumber,
    required this.nationality,
    this.nricNumber,
    this.race,
    this.gender,
    required this.addressLine1,
    required this.city,
    required this.postcode,
    required this.state,
    required this.country,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.emergencyContactEmail,
    this.remarks,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? 'Individual',
      altPhoneNumber: json['alt_phone_number'],
      nationality: json['nationality'] ?? 'N/A',
      nricNumber: json['nric_number'],
      race: json['race'],
      gender: json['gender'],
      addressLine1: json['address_line_1'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      postcode: json['postcode'] ?? 'N/A',
      state: json['state'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactRelationship: json['emergency_contact_relationship'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactEmail: json['emergency_contact_email'],
      remarks: json['remarks'],
    );
  }
}