import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceName;
  final String serviceDescription;
  final String templeId;
  final String img;

  Service({
    required this.serviceName,
    required this.serviceDescription,
    required this.templeId,
    required this.img,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      serviceName: data['serviceName'] ?? '',
      serviceDescription: data['serviceDescription'] ?? '',
      templeId: (data['templeId'] ?? '').trim(), // Trim whitespace
      img: data['img'] ?? '',
    );
  }
}

class Temple {
  final String templeId;
  final String templeName;
  final List<String> photos;

  Temple({
    required this.templeId,
    required this.templeName,
    required this.photos,
  });

  factory Temple.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Temple(
      templeId: (data['templeId'] ?? '').trim(), // Trim whitespace
      templeName: data['temple_name'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }
}
class VolunteeringRequest {
  final String eventName;
  final String festivalName;
  final String status;
  final DateTime dateTime;
  final String templeId;
  final String userId; // Add this
  final String username;

  VolunteeringRequest({
    required this.eventName,
    required this.festivalName,
    required this.status,
    required this.dateTime,
    required this.templeId,
    required this.userId, // Add this
    required this.username,
  });

  factory VolunteeringRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VolunteeringRequest(
      eventName: data['eventName'] ?? '',
      festivalName: data['festivalName'] ?? '',
      status: data['status'] ?? '',
      dateTime: (data['date_time'] as Timestamp).toDate(),
      templeId: data['templeId'] ?? '',
      userId: data['userId'] ?? '', // Add this
      username: data['username'] ?? '',
    );
  }
}