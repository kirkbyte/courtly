enum Surface { hard, clay, grass }

enum CourtType { tennis, padel }

enum BookingStatus { active, cancelled }

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class Club {
  const Club({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.openHour,
    required this.closeHour,
    required this.surfaces,
    required this.courtTypes,
    required this.hasIndoor,
    required this.hasOutdoor,
  });

  final String id;
  final String name;
  final String address;
  final double rating;

  /// Opening hours, local time: courts are bookable in [openHour, closeHour).
  final int openHour;
  final int closeHour;

  // Denormalized summaries of the club's courts, used by catalog filters.
  final Set<Surface> surfaces;
  final Set<CourtType> courtTypes;
  final bool hasIndoor;
  final bool hasOutdoor;
}

class Court {
  const Court({
    required this.id,
    required this.clubId,
    required this.name,
    required this.surface,
    required this.type,
    required this.isIndoor,
    required this.pricePerHour,
  });

  final String id;
  final String clubId;
  final String name;
  final Surface surface;
  final CourtType type;
  final bool isIndoor;
  final double pricePerHour;
}

class Booking {
  const Booking({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.courtId,
    required this.courtName,
    required this.start,
    required this.durationHours,
    required this.price,
    required this.status,
  });

  factory Booking.fromJson(Map<String, Object?> json) => Booking(
        id: json['id']! as String,
        clubId: json['clubId']! as String,
        clubName: json['clubName']! as String,
        courtId: json['courtId']! as String,
        courtName: json['courtName']! as String,
        start: DateTime.parse(json['start']! as String),
        durationHours: json['durationHours']! as int,
        price: (json['price']! as num).toDouble(),
        status: BookingStatus.values.byName(json['status']! as String),
      );

  final String id;
  final String clubId;
  final String clubName;
  final String courtId;
  final String courtName;

  /// Start of the booked interval, local time.
  final DateTime start;
  final int durationHours;
  final double price;
  final BookingStatus status;

  DateTime get end => start.add(Duration(hours: durationHours));

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        clubId: clubId,
        clubName: clubName,
        courtId: courtId,
        courtName: courtName,
        start: start,
        durationHours: durationHours,
        price: price,
        status: status ?? this.status,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'clubId': clubId,
        'clubName': clubName,
        'courtId': courtId,
        'courtName': courtName,
        'start': start.toIso8601String(),
        'durationHours': durationHours,
        'price': price,
        'status': status.name,
      };

  @override
  bool operator ==(Object other) =>
      other is Booking &&
      other.id == id &&
      other.clubId == clubId &&
      other.clubName == clubName &&
      other.courtId == courtId &&
      other.courtName == courtName &&
      other.start == start &&
      other.durationHours == durationHours &&
      other.price == price &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, start, status);
}
