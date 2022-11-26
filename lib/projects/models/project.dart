import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/// Project.
@immutable
class Project {
  /// Default constructor.
  const Project({
    required this.id,
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
        saveData = {},
        id = '';

  /// From snapshot.
  factory Project.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;

    return Project(
      id: snapshot.id,
      title: data['title'] ?? '',
      userIds: List<String>.from(data['userIds']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      saveData: data['saveData'] ?? {},
    );
  }

  /// Id.
  final String id;

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
      'id': id,
      'title': title,
      'userIds': userIds,
      'createdAt': createdAt,
      'saveData': saveData,
    };
  }

  /// Returns a map of the project used for creation on the backend while
  /// requiring the needed parameters.
  static Map<String, dynamic> forCreation({
    required String title,
    required List<String> userIds,
    required FieldValue createdAt,
  }) {
    return {
      'title': title,
      'userIds': userIds,
      'createdAt': createdAt,
    };
  }
}
