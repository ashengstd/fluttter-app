import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'sc.dart';
import 'student.dart';
import 'course.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Future<Database> database;

  // Initialize the logger
  final logger = Logger();

  Future<void> _insertTestData(Database db) async {
    try {
      final students = [
        Student(
            sno: 'S1',
            sname: 'John Doe',
            ssex: 'Male',
            sbirthdate: DateTime(2000, 1, 1),
            smajor: 'CS'),
        Student(
            sno: 'S2',
            sname: 'Jane Doe',
            ssex: 'Female',
            sbirthdate: DateTime(2001, 2, 2),
            smajor: 'Math'),
        Student(
            sno: 'S3',
            sname: 'Alice Smith',
            ssex: 'Female',
            sbirthdate: DateTime(2000, 3, 3),
            smajor: 'Physics'),
        Student(
            sno: 'S4',
            sname: 'Bob Johnson',
            ssex: 'Male',
            sbirthdate: DateTime(2001, 4, 4),
            smajor: 'Chemistry'),
        Student(
            sno: 'S5',
            sname: 'Charlie Brown',
            ssex: 'Male',
            sbirthdate: DateTime(2002, 5, 5),
            smajor: 'Biology'),
        Student(
            sno: 'S6',
            sname: 'David Wilson',
            ssex: 'Male',
            sbirthdate: DateTime(2003, 6, 6),
            smajor: 'Economics'),
        Student(
            sno: 'S7',
            sname: 'Ella Davis',
            ssex: 'Female',
            sbirthdate: DateTime(2002, 7, 7),
            smajor: 'History'),
        Student(
            sno: 'S8',
            sname: 'Frank Harris',
            ssex: 'Male',
            sbirthdate: DateTime(2001, 8, 8),
            smajor: 'Literature'),
        Student(
            sno: 'S9',
            sname: 'Grace Martin',
            ssex: 'Female',
            sbirthdate: DateTime(2000, 9, 9),
            smajor: 'Art'),
        Student(
            sno: 'S10',
            sname: 'Hank White',
            ssex: 'Male',
            sbirthdate: DateTime(2003, 10, 10),
            smajor: 'Music'),
        Student(
            sno: 'S11',
            sname: 'Ivy Thompson',
            ssex: 'Female',
            sbirthdate: DateTime(2004, 11, 11),
            smajor: 'Philosophy'),
        Student(
            sno: 'S12',
            sname: 'Jack Garcia',
            ssex: 'Male',
            sbirthdate: DateTime(2005, 12, 12),
            smajor: 'Engineering'),
        Student(
            sno: 'S13',
            sname: 'Katie Martinez',
            ssex: 'Female',
            sbirthdate: DateTime(2006, 1, 1),
            smajor: 'Sociology'),
        Student(
            sno: 'S14',
            sname: 'Leo Robinson',
            ssex: 'Male',
            sbirthdate: DateTime(2007, 2, 2),
            smajor: 'Psychology'),
      ];

      final courses = [
        Course(cno: 'C1', cname: 'Mathematics', ccredit: 3, cpno: ''),
        Course(cno: 'C2', cname: 'Computer Science', ccredit: 4, cpno: ''),
        Course(cno: 'C3', cname: 'Physics', ccredit: 3, cpno: ''),
        Course(cno: 'C4', cname: 'Chemistry', ccredit: 4, cpno: ''),
        Course(cno: 'C5', cname: 'Biology', ccredit: 3, cpno: ''),
        Course(cno: 'C6', cname: 'Economics', ccredit: 4, cpno: ''),
        Course(cno: 'C7', cname: 'History', ccredit: 3, cpno: ''),
        Course(cno: 'C8', cname: 'Literature', ccredit: 4, cpno: ''),
        Course(cno: 'C9', cname: 'Art', ccredit: 3, cpno: ''),
        Course(cno: 'C10', cname: 'Music', ccredit: 4, cpno: ''),
        Course(cno: 'C11', cname: 'Philosophy', ccredit: 3, cpno: ''),
        Course(cno: 'C12', cname: 'Engineering', ccredit: 4, cpno: ''),
        Course(cno: 'C13', cname: 'Sociology', ccredit: 3, cpno: ''),
        Course(cno: 'C14', cname: 'Psychology', ccredit: 4, cpno: ''),
      ];

      final scs = [
        SC(
            sno: 'S1',
            cno: 'C1',
            grade: 90,
            semester: '2023 Spring',
            teachingClass: 'T1'),
        SC(
            sno: 'S2',
            cno: 'C2',
            grade: 85,
            semester: '2023 Fall',
            teachingClass: 'T2'),
        SC(
            sno: 'S3',
            cno: 'C3',
            grade: 88,
            semester: '2023 Spring',
            teachingClass: 'T3'),
        SC(
            sno: 'S4',
            cno: 'C4',
            grade: 92,
            semester: '2023 Fall',
            teachingClass: 'T4'),
        SC(
            sno: 'S5',
            cno: 'C5',
            grade: 80,
            semester: '2023 Spring',
            teachingClass: 'T5'),
        SC(
            sno: 'S6',
            cno: 'C6',
            grade: 78,
            semester: '2023 Fall',
            teachingClass: 'T6'),
        SC(
            sno: 'S7',
            cno: 'C7',
            grade: 85,
            semester: '2023 Spring',
            teachingClass: 'T7'),
        SC(
            sno: 'S8',
            cno: 'C8',
            grade: 91,
            semester: '2023 Fall',
            teachingClass: 'T8'),
        SC(
            sno: 'S9',
            cno: 'C9',
            grade: 87,
            semester: '2023 Spring',
            teachingClass: 'T9'),
        SC(
            sno: 'S10',
            cno: 'C10',
            grade: 89,
            semester: '2023 Fall',
            teachingClass: 'T10'),
        SC(
            sno: 'S11',
            cno: 'C11',
            grade: 84,
            semester: '2023 Spring',
            teachingClass: 'T11'),
        SC(
            sno: 'S12',
            cno: 'C12',
            grade: 77,
            semester: '2023 Fall',
            teachingClass: 'T12'),
        SC(
            sno: 'S13',
            cno: 'C13',
            grade: 93,
            semester: '2023 Spring',
            teachingClass: 'T13'),
        SC(
            sno: 'S14',
            cno: 'C14',
            grade: 95,
            semester: '2023 Fall',
            teachingClass: 'T14'),
      ];

      for (var student in students) {
        await db.insert('Student', student.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort);
      }
      logger.i("Inserted students");

      for (var course in courses) {
        await db.insert('Course', course.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort);
      }
      logger.i("Inserted courses");

      for (var sc in scs) {
        await db.insert('SC', sc.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort);
      }
      logger.i("Inserted SCs");
    } catch (e) {
      logger.e("Error inserting test data: $e");
    }
  }

  Future<void> openDb() async {
    try {
      String path = join(await getDatabasesPath(), 'school_database.db');
      database = openDatabase(
        path,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Student('
            'Sno TEXT PRIMARY KEY,'
            'Sname TEXT,'
            'Ssex TEXT,'
            'Sbirthdate TEXT,'
            'Smajor TEXT)',
          );
          logger.i("Created Student table");
          await db.execute(
            'CREATE TABLE Course('
            'Cno TEXT PRIMARY KEY,'
            'Cname TEXT,'
            'Ccredit INTEGER,'
            'Cpno TEXT)',
          );
          logger.i("Created Course table");
          await db.execute(
            'CREATE TABLE SC('
            'Sno TEXT,'
            'Cno TEXT,'
            'Grade INTEGER,'
            'Semester TEXT,'
            'TeachingClass TEXT,'
            'PRIMARY KEY (Sno, Cno),'
            'FOREIGN KEY (Sno) REFERENCES Student(Sno),'
            'FOREIGN KEY (Cno) REFERENCES Course(Cno))',
          );
          logger.i("Created SC table");
          await _insertTestData(db);
        },
        version: 1,
      );
    } catch (e) {
      logger.e("Error opening database: $e");
    }
  }

  Future<void> insertStudent(Student student) async {
    try {
      final db = await database;
      await db.insert(
        'Student',
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      logger.e("Error inserting student: $e");
    }
  }

  Future<List<Student>> getStudents(int length) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('Student');
      if (length >= maps.length) {
        return List.generate(maps.length, (i) {
          return Student.fromMap(maps[i]);
        });
      }
      return List.generate(length, (i) {
        return Student.fromMap(maps[i]);
      });
    } catch (e) {
      logger.e("Error retrieving students: $e");
      return [];
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      final db = await database;
      await db.update(
        'Student',
        student.toMap(),
        where: 'Sno = ?',
        whereArgs: [student.sno],
      );
    } catch (e) {
      logger.e("Error updating student: $e");
    }
  }

  Future<void> deleteStudent(String sno) async {
    try {
      final db = await database;
      await db.delete(
        'SC',
        where: 'sno = ?',
        whereArgs: [sno],
      );
      await db.delete(
        'Student',
        where: 'Sno = ?',
        whereArgs: [sno],
      );
    } catch (e) {
      logger.e("Error deleting student: $e");
    }
  }

  Future<void> insertCourse(Course course) async {
    try {
      final db = await database;
      await db.insert(
        'Course',
        course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      logger.e("Error inserting course: $e");
    }
  }

  Future<List<Course>> getCourses(int length) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('Course');
      if (length >= maps.length) {
        return List.generate(maps.length, (i) {
          return Course.fromMap(maps[i]);
        });
      }
      return List.generate(length, (i) {
        return Course.fromMap(maps[i]);
      });
    } catch (e) {
      logger.e("Error retrieving courses: $e");
      return [];
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      final db = await database;
      await db.update(
        'Course',
        course.toMap(),
        where: 'Cno = ?',
        whereArgs: [course.cno],
      );
    } catch (e) {
      logger.e("Error updating course: $e");
    }
  }

  Future<void> deleteCourse(String cno) async {
    try {
      final db = await database;
      await db.delete(
        'SC',
        where: 'cno = ?',
        whereArgs: [cno],
      );
      await db.delete(
        'Course',
        where: 'cno = ?',
        whereArgs: [cno],
      );
    } catch (e) {
      logger.e("Error deleting course: $e");
    }
  }

  Future<void> insertSc(SC sc) async {
    try {
      final db = await database;
      await db.insert(
        'SC',
        sc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      logger.e("Error inserting SC: $e");
    }
  }

  Future<List<SC>> getScs(int length) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('SC');
      if (length >= maps.length) {
        return List.generate(maps.length, (i) {
          return SC.fromMap(maps[i]);
        });
      }
      return List.generate(length, (i) {
        return SC.fromMap(maps[i]);
      });
    } catch (e) {
      logger.e("Error retrieving SCs: $e");
      return [];
    }
  }

  Future<void> updateSc(SC sc) async {
    try {
      final db = await database;
      await db.update(
        'SC',
        sc.toMap(),
        where: 'Sno = ? AND Cno = ?',
        whereArgs: [sc.sno, sc.cno],
      );
    } catch (e) {
      logger.e("Error updating SC: $e");
    }
  }

  Future<void> deleteSc(String sno, String cno) async {
    try {
      final db = await database;
      await db.delete(
        'SC',
        where: 'Sno = ? AND Cno = ?',
        whereArgs: [sno, cno],
      );
    } catch (e) {
      logger.e("Error deleting SC: $e");
    }
  }

  Future<Student> getStudentBySno(String sno) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Student',
        where: 'sno = ?',
        whereArgs: [sno],
      );

      if (maps.isNotEmpty) {
        return Student.fromMap(maps.first);
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      logger.e("Error retrieving student by sno: $e");
      throw Exception('Error retrieving student by sno');
    }
  }

  Future<Course> getCourseByCno(String cno) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Course',
        where: 'cno = ?',
        whereArgs: [cno],
      );

      if (maps.isNotEmpty) {
        return Course.fromMap(maps.first);
      } else {
        throw Exception('Course not found');
      }
    } catch (e) {
      logger.e("Error retrieving course by cno: $e");
      throw Exception('Error retrieving course by cno');
    }
  }
}
