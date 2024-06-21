import 'package:flutter/material.dart';
import '../UI/widgets/animated_floating_action_button.dart';
import '../database/sc.dart';
import '../database/course.dart';
import '../database/student.dart';
import '../database/dataservice.dart';

class SCPage extends StatefulWidget {
  const SCPage({super.key});

  @override
  SCPageState createState() => SCPageState();
}

class SCPageState extends State<SCPage> with SingleTickerProviderStateMixin {
  double scrolledUnderElevation = 2.0;
  late DatabaseService _DatabaseService;
  late Future<List<SC>> _scList;
  late Future<List<Student>> _studentList;
  late Future<List<Course>> _courseList;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<SC> _scs = [];
  List<SC> _filteredScs = [];
  List<Student> _students = [];
  List<Course> _courses = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _DatabaseService = DatabaseService();
    _scList = _initializeScList();
    _studentList = _initializeStudentList();
    _courseList = _initializeCourseList();
    _searchController.addListener(_filterScs);
  }

  Future<List<SC>> _initializeScList() async {
    await _DatabaseService.openDb();
    return _refreshScList();
  }

  Future<List<SC>> _refreshScList() async {
    final scs = await _DatabaseService.getScs(100);
    setState(() {
      _scs = scs;
      _filteredScs = scs;
    });
    return scs;
  }

  Future<List<Student>> _initializeStudentList() async {
    await _DatabaseService.openDb();
    return _DatabaseService.getStudents(100);
  }

  Future<List<Course>> _initializeCourseList() async {
    await _DatabaseService.openDb();
    return _DatabaseService.getCourses(100);
  }

  void _filterScs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredScs = _scs.where((sc) {
        final student = _students.firstWhere((student) => student.sno == sc.sno,
            orElse: () => Student(
                sno: '',
                sname: '',
                ssex: '',
                sbirthdate: DateTime.now(),
                smajor: ''));
        final course = _courses.firstWhere((course) => course.cno == sc.cno,
            orElse: () => Course(cno: '', cname: '', ccredit: 0, cpno: ''));

        return student.sname.toLowerCase().contains(query) ||
            course.cname.toLowerCase().contains(query) ||
            sc.sno.toLowerCase().contains(query) ||
            sc.cno.toLowerCase().contains(query) ||
            sc.grade.toString().contains(query) ||
            sc.semester.toLowerCase().contains(query) ||
            sc.teachingClass.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showForm({SC? sc}) async {
    final snoController = TextEditingController(text: sc?.sno);
    final cnoController = TextEditingController(text: sc?.cno);
    final gradeController =
        TextEditingController(text: sc != null ? sc.grade.toString() : '');
    final semesterController = TextEditingController(text: sc?.semester);
    final teachingClassController =
        TextEditingController(text: sc?.teachingClass);
    String? errorMessage;
    String? selectedStudentSno = sc?.sno;
    String? selectedCourseCno = sc?.cno;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(sc == null ? 'Add SC' : 'Edit SC'),
              content: SingleChildScrollView(
                child: IntrinsicWidth(
                  stepWidth: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<List<Student>>(
                        future: _studentList,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          _students = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            value: selectedStudentSno,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Student'),
                            items: _students.map((student) {
                              return DropdownMenuItem<String>(
                                value: student.sno,
                                child:
                                    Text('${student.sname} - ${student.sno}'),
                              );
                            }).toList(),
                            onChanged: sc == null
                                ? (value) {
                                    setState(() {
                                      selectedStudentSno = value;
                                      snoController.text = value ?? '';
                                    });
                                  }
                                : null,
                            disabledHint: sc != null
                                ? Text('${sc.sno} - ${sc.sno}')
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Course>>(
                        future: _courseList,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          _courses = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: Theme.of(context).textTheme.bodyMedium,
                            value: selectedCourseCno,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Course'),
                            items: _courses.map((course) {
                              return DropdownMenuItem<String>(
                                value: course.cno,
                                child: Text('${course.cname} - ${course.cno}'),
                              );
                            }).toList(),
                            onChanged: sc == null
                                ? (value) {
                                    setState(() {
                                      selectedCourseCno = value;
                                      cnoController.text = value ?? '';
                                    });
                                  }
                                : null,
                            disabledHint: sc != null
                                ? Text('${sc.sno} - ${sc.cno}')
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: gradeController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Grade'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: semesterController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Semester'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: teachingClassController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Teaching Class'),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final sno = snoController.text;
                    final cno = cnoController.text;
                    final grade = int.tryParse(gradeController.text);
                    final semester = semesterController.text;
                    final teachingClass = teachingClassController.text;

                    if (semester.isEmpty ||
                        teachingClass.isEmpty ||
                        grade == null) {
                      setState(() {
                        errorMessage = 'All fields are required.';
                      });
                      return;
                    }

                    if (grade < 0 || grade > 100) {
                      setState(() {
                        errorMessage = 'Grade must be between 0 and 100.';
                      });
                      return;
                    }

                    if (sc == null) {
                      bool scExists = _scs.any((existingSc) =>
                          existingSc.sno == sno &&
                          existingSc.cno == cno &&
                          existingSc != sc);

                      if (scExists) {
                        setState(() {
                          errorMessage = 'SC already exists';
                        });
                        return;
                      }
                    }

                    if (sc == null) {
                      final newSc = SC(
                        sno: sno,
                        cno: cno,
                        grade: grade,
                        semester: semester,
                        teachingClass: teachingClass,
                      );
                      await _DatabaseService.insertSc(newSc);
                      if (!mounted) return;
                      setState(() {
                        _scs.add(newSc);
                        _filteredScs = _scs;
                        _listKey.currentState?.insertItem(_scs.length - 1);
                      });
                    } else {
                      final updatedSc = SC(
                        sno: sno,
                        cno: cno,
                        grade: grade,
                        semester: semester,
                        teachingClass: teachingClass,
                      );
                      await _DatabaseService.updateSc(updatedSc);
                      if (!mounted) return;
                      setState(() {
                        final index = _scs.indexOf(sc);
                        _scs[index] = updatedSc;
                        _filteredScs = _scs;
                      });
                    }

                    _refreshScList();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(sc == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteSc(String sno, String cno) async {
    await _DatabaseService.deleteSc(sno, cno);
    final index = _scs.indexWhere((sc) => sc.sno == sno && sc.cno == cno);
    if (index >= 0 && index < _scs.length) {
      final removedSc = _scs.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildItem(removedSc, animation),
        duration: const Duration(milliseconds: 300),
      );
      _refreshScList();
    }
  }

  Widget _buildItem(SC sc, Animation<double> animation) {
    return FutureBuilder<Student>(
      future: _DatabaseService.getStudentBySno(sc.sno),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (studentSnapshot.hasError) {
          return ListTile(
            title: Text('Error: ${studentSnapshot.error}'),
          );
        } else {
          final student = studentSnapshot.data!;
          return FutureBuilder<Course>(
            future: _DatabaseService.getCourseByCno(sc.cno),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (courseSnapshot.hasError) {
                return ListTile(
                  title: Text('Error: ${courseSnapshot.error}'),
                );
              } else {
                final course = courseSnapshot.data!;
                return SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                    elevation: 6,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      title: Text(
                        '${student.sname} - ${course.cname}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Sno: ${sc.sno}, Cno: ${sc.cno}, Grade: ${sc.grade}, Semester: ${sc.semester}, Teaching Class: ${sc.teachingClass}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          student.sname.substring(0, 1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Theme.of(context).iconTheme.color),
                            onPressed: () => _showForm(sc: sc),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () => _deleteSc(sc.sno, sc.cno),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text('SC Manager'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear,
                        color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SC>>(
                future: _scList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _filteredScs.isNotEmpty
                      ? AnimatedList(
                          key: _listKey,
                          initialItemCount: _filteredScs.length,
                          itemBuilder: (context, index, animation) {
                            if (index < 0 || index >= _filteredScs.length) {
                              return Container(); // 返回一个空容器或者其他处理方式
                            }
                            return _buildItem(_filteredScs[index], animation);
                          },
                        )
                      : const Center(child: Text('No SC found'));
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        heroTag: "sc_fab",
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
