import 'package:intl/intl.dart';

class Student {
  String sno;
  String sname;
  String ssex;
  DateTime sbirthdate;
  String smajor;

  Student(
      {required this.sno,
      required this.sname,
      required this.ssex,
      required this.sbirthdate,
      required this.smajor});

  Map<String, dynamic> toMap() {
    final dateFormat = DateFormat('yyyy-MM-dd').format(sbirthdate);
    return {
      'Sno': sno,
      'Sname': sname,
      'Ssex': ssex,
      'Sbirthdate': dateFormat,
      'Smajor': smajor,
    };
  }

  static Student fromMap(Map<String, dynamic> map) {
    return Student(
      sno: map['Sno'],
      sname: map['Sname'],
      ssex: map['Ssex'],
      sbirthdate: DateTime.parse(map['Sbirthdate']),
      smajor: map['Smajor'],
    );
  }
}
