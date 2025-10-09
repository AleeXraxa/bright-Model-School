import 'package:get/get.dart';

class ClassModel {
  final int? id;
  final String className;
  final String section;
  final RxInt studentCount;

  ClassModel({
    this.id,
    required this.className,
    required this.section,
    int studentCount = 0,
  }) : studentCount = studentCount.obs;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'class': className,
    'section': section,
    'student_count': studentCount.value,
  };

  factory ClassModel.fromMap(Map<String, dynamic> map) => ClassModel(
    id: map['id'] as int?,
    className: map['class'] as String,
    section: map['section'] as String,
    studentCount: map['student_count'] as int? ?? 0,
  );
}
