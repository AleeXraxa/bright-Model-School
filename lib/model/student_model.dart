class StudentModel {
  final int? id;
  final int? classId; // Foreign key to ClassModel.id
  final String name;
  final String roll;
  final String grNo;
  final String studentClass;
  final String section;
  final String fatherName;
  final String caste;
  final String placeOfBirth;
  final String dateOfBirthFigures;
  final String dateOfBirthWords;
  final String gender;
  final String religion;
  final String fatherContact;
  final String motherContact;
  final String address;
  final String admissionFees;
  final String monthlyFees;
  final String accountNumber;
  final String contact;
  final String status; // Active, Inactive, Pending
  final String admissionDate; // Auto-generated on admission

  StudentModel({
    this.id,
    this.classId,
    required this.name,
    required this.roll,
    required this.grNo,
    required this.studentClass,
    required this.section,
    required this.fatherName,
    required this.caste,
    required this.placeOfBirth,
    required this.dateOfBirthFigures,
    required this.dateOfBirthWords,
    required this.gender,
    required this.religion,
    required this.fatherContact,
    required this.motherContact,
    required this.address,
    required this.admissionFees,
    required this.monthlyFees,
    required this.accountNumber,
    required this.contact,
    required this.status,
    required this.admissionDate,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    if (classId != null) 'class_id': classId,
    'name': name,
    'roll': roll,
    'gr_no': grNo,
    'class': studentClass,
    'section': section,
    'father_name': fatherName,
    'caste': caste,
    'place_of_birth': placeOfBirth,
    'date_of_birth_figures': dateOfBirthFigures,
    'date_of_birth_words': dateOfBirthWords,
    'gender': gender,
    'religion': religion,
    'father_contact': fatherContact,
    'mother_contact': motherContact,
    'address': address,
    'admission_fees': admissionFees,
    'monthly_fees': monthlyFees,
    'account_number': accountNumber,
    'contact': contact,
    'status': status,
    'admission_date': admissionDate,
  };

  factory StudentModel.fromMap(Map<String, dynamic> map) => StudentModel(
    id: map['id'] as int?,
    classId: map['class_id'] as int?,
    name: map['name'] as String,
    roll: map['roll'] as String,
    grNo: map['gr_no'] as String? ?? '',
    studentClass: map['class'] as String,
    section: map['section'] as String,
    fatherName: map['father_name'] as String,
    caste: map['caste'] as String? ?? '',
    placeOfBirth: map['place_of_birth'] as String? ?? '',
    dateOfBirthFigures: map['date_of_birth_figures'] as String? ?? '',
    dateOfBirthWords: map['date_of_birth_words'] as String? ?? '',
    gender: map['gender'] as String? ?? '',
    religion: map['religion'] as String? ?? '',
    fatherContact: map['father_contact'] as String? ?? '',
    motherContact: map['mother_contact'] as String? ?? '',
    address: map['address'] as String? ?? '',
    admissionFees: map['admission_fees'] as String? ?? '',
    monthlyFees: map['monthly_fees'] as String? ?? '',
    accountNumber: map['account_number'] as String? ?? '',
    contact: map['contact'] as String,
    status: map['status'] as String,
    admissionDate: map['admission_date'] as String? ?? '',
  );
}
