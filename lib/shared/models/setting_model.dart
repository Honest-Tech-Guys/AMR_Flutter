class Setting {
  final int id;
  final String? vrUrl;
  final int? noBed;
  final int? noBath;
  final String? preferredGender;
  final String? preferredRace;
  final int cookingFacilities;
  final int fridge;
  final int wifi;
  final int washingMachine;
  final int cleaning;
  final int waterHeater;
  final int dryer;
  final int balcony;
  final String? roomImage;
  final String rental;
  final String? bedType;
  final String? bathType;
  final String? aircond;
  final String? window;
  final String? typeOfWalls;
  final String? furnishing;
  final String? furnishingDetails;
  final String? meterType;
  final String? electricityTracking;
  final String? electricityRate;
  final String? sizeSqft;

  Setting({
    required this.id,
    this.vrUrl,
    this.noBed,
    this.noBath,
    this.preferredGender,
    this.preferredRace,
    required this.cookingFacilities,
    required this.fridge,
    required this.wifi,
    required this.washingMachine,
    required this.cleaning,
    required this.waterHeater,
    required this.dryer,
    required this.balcony,
    this.roomImage,
    required this.rental,
    this.bedType,
    this.bathType,
    this.aircond,
    this.window,
    this.typeOfWalls,
    this.furnishing,
    this.furnishingDetails,
    this.meterType,
    this.electricityTracking,
    this.electricityRate,
    this.sizeSqft,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as int,
      vrUrl: json['vr_url'] as String?,
      noBed: json['no_bed'] as int?,
      noBath: json['no_bath'] as int?,
      preferredGender: json['preferred_gender'] as String?,
      preferredRace: json['preferred_race'] as String?,
      cookingFacilities: json['cooking_facilities'] as int,
      fridge: json['fridge'] as int,
      wifi: json['wifi'] as int,
      washingMachine: json['washing_machine'] as int,
      cleaning: json['cleaning'] as int,
      waterHeater: json['water_heater'] as int,
      dryer: json['dryer'] as int,
      balcony: json['balcony'] as int,
      roomImage: json['room_image'] as String?,
      rental: json['rental'] as String,
      bedType: json['bed_type'] as String?,
      bathType: json['bath_type'] as String?,
      aircond: json['aircond'] as String?,
      window: json['window'] as String?,
      typeOfWalls: json['type_of_walls'] as String?,
      furnishing: json['furnishing'] as String?,
      furnishingDetails: json['furnishing_details'] as String?,
      meterType: json['meter_type'] as String?,
      electricityTracking: json['electricity_tracking'] as String?,
      electricityRate: json['electricity_rate'] as String?,
      sizeSqft: json['size_sqft'] as String?,
    );
  }
}
