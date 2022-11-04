import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/// Project.
@immutable
class Project {
  /// Default constructor.
  const Project({
    required this.title,
    required this.userIds,
    required this.createdAt,
  });

  /// Empty project.
  Project.empty()
      : title = '',
        userIds = [],
        createdAt = Timestamp.now();

  /// From snapshot.
  factory Project.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;

    return Project(
      title: data['title'] ?? '',
      userIds: List<String>.from(data['userIds']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// User ids.
  final List<String> userIds;

  /// Title
  final String title;

  /// CreatedAt.
  final Timestamp createdAt;

  /// Collections save.

  /// To map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'userIds': userIds,
      'createdAt': createdAt,
    };
  }
}
