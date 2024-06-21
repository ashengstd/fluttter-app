import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../UI/widgets/animated_floating_action_button.dart';
import '../database/student.dart';
import '../database/dataservice.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage>
    with SingleTickerProviderStateMixin {
  double scrolledUnderElevation = 2.0;
  late DatabaseService _databaseService;
  late Future<List<Student>> _studentList;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _studentList = _initializeStudentList();
    _searchController.addListener(_filterStudents);
  }

  Future<List<Student>> _initializeStudentList() async {
    await _databaseService.openDb();
    return _refreshStudentList();
  }

  Future<List<Student>> _refreshStudentList() async {
    final students = await _databaseService.getStudents(100);
    setState(() {
      _students = students;
      _filteredStudents = students;
    });
    return students;
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student.sname.toLowerCase().contains(query) ||
            student.sno.toLowerCase().contains(query) ||
            student.ssex.toLowerCase().contains(query) ||
            student.smajor.toLowerCase().contains(query);
      }).toList();
      _listKey.currentState?.setState(() {}); // 刷新AnimatedList
    });
  }

  void _showForm({Student? student}) async {
    final snoController = TextEditingController(text: student?.sno);
    final snameController = TextEditingController(text: student?.sname);
    final sbirthdateController = TextEditingController(
        text: student != null
            ? DateFormat('yyyy-MM-dd').format(student.sbirthdate)
            : '');
    final smajorController = TextEditingController(text: student?.smajor);
    String? errorMessage;
    String selectedSex = student?.ssex ?? 'Male'; // 默认选择 'male'

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(student == null ? 'Add Student' : 'Edit Student'),
              content: SingleChildScrollView(
                child: IntrinsicWidth(
                  stepWidth: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: snoController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Sno'),
                        style: const TextStyle(fontSize: 18),
                        readOnly: student != null,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: snameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Sname'),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedSex,
                        icon: const Icon(Icons.arrow_downward),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: ['Male', 'Female']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedSex = value;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Ssex'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: sbirthdateController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Sbirthdate'),
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: student != null
                                ? student.sbirthdate
                                : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            sbirthdateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: smajorController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Smajor'),
                        style: const TextStyle(fontSize: 18),
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
                    final sname = snameController.text;
                    final sbirthdate = DateFormat('yyyy-MM-dd')
                        .tryParse(sbirthdateController.text);
                    final smajor = smajorController.text;

                    if (sno.isEmpty ||
                        sname.isEmpty ||
                        smajor.isEmpty ||
                        sbirthdate == null) {
                      setState(() {
                        errorMessage = 'All fields are required.';
                      });
                      return;
                    }

                    if (student == null) {
                      bool snoExists =
                          _students.any((s) => s.sno == sno && s != student);
                      if (snoExists) {
                        setState(() {
                          errorMessage = 'Sno already exists.';
                        });
                        return;
                      }
                    }

                    if (student == null) {
                      final newStudent = Student(
                        sno: sno,
                        sname: sname,
                        ssex: selectedSex,
                        sbirthdate: sbirthdate,
                        smajor: smajor,
                      );
                      await _databaseService.insertStudent(newStudent);
                      if (!mounted) return;
                      setState(() {
                        _students.add(newStudent);
                        _filteredStudents = _students;
                        _listKey.currentState?.insertItem(_students.length - 1);
                      });
                    } else {
                      final updatedStudent = Student(
                        sno: sno,
                        sname: sname,
                        ssex: selectedSex,
                        sbirthdate: sbirthdate,
                        smajor: smajor,
                      );
                      await _databaseService.updateStudent(updatedStudent);
                      if (!mounted) return;
                      setState(() {
                        final index = _students.indexOf(student);
                        _students[index] = updatedStudent;
                        _filteredStudents = _students;
                      });
                    }

                    _refreshStudentList();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(student == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteStudent(String sno) async {
    await _databaseService.deleteStudent(sno);
    final index = _students.indexWhere((student) => student.sno == sno);
    final removedStudent = _students.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedStudent, animation),
      duration: const Duration(milliseconds: 300),
    );
    _refreshStudentList();
  }

  Widget _buildItem(Student student, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          title: Text(
            '${student.sno} - ${student.sname}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          subtitle: Text(
            'Sex: ${student.ssex}, Birthdate: ${DateFormat('yyyy-MM-dd').format(student.sbirthdate)}, Major: ${student.smajor}',
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
                icon:
                    Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                onPressed: () => _showForm(student: student),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => _deleteStudent(student.sno),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text('Student Manager'),
        centerTitle: true, // 标题居中
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black, // 根据主题动态设置字体颜色
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
                    color: Theme.of(context).hintColor, // 使用主题的提示颜色
                    fontStyle: FontStyle.italic,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color, // 使用主题的图标颜色
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .inputDecorationTheme
                      .fillColor, // 使用主题的填充颜色
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, // 使用主题的边框颜色
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // 使用主题的主颜色
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
                  color:
                      Theme.of(context).textTheme.bodyLarge!.color, // 使用主题的文本颜色
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _studentList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _filteredStudents.isNotEmpty
                      ? AnimatedList(
                          key: _listKey,
                          initialItemCount: _filteredStudents.length,
                          itemBuilder: (context, index, animation) {
                            if (index < 0 ||
                                index >= _filteredStudents.length) {
                              return Container(); // 返回一个空容器或者其他处理方式
                            }
                            return _buildItem(
                                _filteredStudents[index], animation);
                          },
                        )
                      : const Center(child: Text('No students found'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        heroTag: "student_fab", // Add this line
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
