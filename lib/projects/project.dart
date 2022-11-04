import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/// Project.
@immutable
class Project {
  /// Default constructor.
  const Project({
    required this.title,
    required this.userIds,
  });

  /// From snapshot.
  factory Project.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;

    return Project(
      title: data['title'] ?? '',
      userIds: List<String>.from(data['userIds']),
    );
  }

  /// User ids.
  final List<String> userIds;

  /// Title
  final String title;

  /// Collections save.
}
