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
    required this.saveData,
  });

  /// Empty project.
  Project.empty()
      : title = '',
        userIds = [],
        createdAt = Timestamp.now(),
        saveData = {};

  /// From snapshot.
  factory Project.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;

    return Project(
      title: data['title'] ?? '',
      userIds: List<String>.from(data['userIds']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      saveData: data['saveData'] ?? {},
    );
  }

  /// User ids.
  final List<String> userIds;

  /// Title
  final String title;

  /// CreatedAt.
  final Timestamp createdAt;

  /// Save data.
  final Map<String, dynamic> saveData;

  /// To map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'userIds': userIds,
      'createdAt': createdAt,
      'saveData': saveData,
    };
  }
}
