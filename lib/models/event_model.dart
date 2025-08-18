import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String groupId;
  final String ownerId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.groupId,
    required this.ownerId,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl:
          data['imageUrl'] ??
          'assets/images/events/apresent.png', // Imagem padrão
      date: (data['date'] as Timestamp).toDate(),
      groupId: data['groupId'] ?? '',
      ownerId: data['ownerId'] ?? '',
    );
  }

  String get formattedDate => DateFormat("dd/MM/y 'às' HH:mm").format(date);
}
