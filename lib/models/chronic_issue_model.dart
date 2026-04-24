import 'package:cloud_firestore/cloud_firestore.dart';

class ChronicIssueModel {
  final String id;
  final String brand;
  final String model;
  final String engineType;
  final String transmissionType;
  final String component;
  final bool isChronic;
  final String issueTitle;
  final String legalStatus;
  final String remedy;
  final List<String> tags;
  final String severity; // 'red' or 'yellow'
  final String symptoms;
  final Map<String, int> provinceStats;

  ChronicIssueModel({
    required this.id,
    required this.brand,
    required this.model,
    this.engineType = '',
    this.transmissionType = '',
    required this.component,
    required this.isChronic,
    required this.issueTitle,
    required this.legalStatus,
    required this.remedy,
    required this.tags,
    required this.severity,
    required this.symptoms,
    required this.provinceStats,
  });

  factory ChronicIssueModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChronicIssueModel(
      id: documentId,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      engineType: data['engine_type'] ?? '',
      transmissionType: data['transmission_type'] ?? '',
      component: data['component'] ?? '',
      isChronic: data['is_chronic'] ?? false,
      issueTitle: data['issue_title'] ?? '',
      legalStatus: data['legal_status'] ?? '',
      remedy: data['remedy'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      severity: data['severity'] ?? 'yellow',
      symptoms: data['symptoms'] ?? '',
      provinceStats: Map<String, int>.from(data['province_stats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'engine_type': engineType,
      'transmission_type': transmissionType,
      'component': component,
      'is_chronic': isChronic,
      'issue_title': issueTitle,
      'legal_status': legalStatus,
      'remedy': remedy,
      'tags': tags,
      'severity': severity,
      'symptoms': symptoms,
      'province_stats': provinceStats,
    };
  }
}
