class SC {
  String sno;
  String cno;
  int grade;
  String semester;
  String teachingClass;

  SC({
    required this.sno,
    required this.cno,
    required this.grade,
    required this.semester,
    required this.teachingClass,
  });

  Map<String, dynamic> toMap() {
    return {
      'Sno': sno,
      'Cno': cno,
      'Grade': grade,
      'Semester': semester,
      'TeachingClass': teachingClass,
    };
  }

  static SC fromMap(Map<String, dynamic> map) {
    return SC(
      sno: map['Sno'],
      cno: map['Cno'],
      grade: map['Grade'],
      semester: map['Semester'],
      teachingClass: map['TeachingClass'],
    );
  }
}
