class Course {
  String cno;
  String cname;
  int ccredit;
  String cpno;

  Course({
    required this.cno,
    required this.cname,
    required this.ccredit,
    required this.cpno,
  });

  Map<String, dynamic> toMap() {
    return {
      'Cno': cno,
      'Cname': cname,
      'Ccredit': ccredit,
      'Cpno': cpno,
    };
  }

  static Course fromMap(Map<String, dynamic> map) {
    return Course(
      cno: map['Cno'],
      cname: map['Cname'],
      ccredit: map['Ccredit'],
      cpno: map['Cpno'],
    );
  }
}
