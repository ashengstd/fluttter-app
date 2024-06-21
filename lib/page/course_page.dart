import 'package:flutter/material.dart';
import '../UI/widgets/animated_floating_action_button.dart';
import '../database/course.dart';
import '../database/dataservice.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage>
    with SingleTickerProviderStateMixin {
  double scrolledUnderElevation = 2.0;
  late DatabaseService _databaseService;
  late Future<List<Course>> _courseList;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _courseList = _initializeCourseList();
    _searchController.addListener(_filterCourses);
  }

  Future<List<Course>> _initializeCourseList() async {
    await _databaseService.openDb();
    return _refreshCourseList();
  }

  Future<List<Course>> _refreshCourseList() async {
    final courses = await _databaseService.getCourses(100);
    setState(() {
      _courses = courses;
      _filteredCourses = courses;
    });
    return courses;
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        return course.cname.toLowerCase().contains(query) ||
            course.cno.toLowerCase().contains(query) ||
            course.cpno.toLowerCase().contains(query) ||
            course.ccredit.toString().contains(query);
      }).toList();
      _listKey.currentState?.setState(() {}); // 刷新AnimatedList
    });
  }

  void _showForm({Course? course}) async {
    final cnoController = TextEditingController(text: course?.cno);
    final cnameController = TextEditingController(text: course?.cname);
    final ccreditController = TextEditingController(
        text: course != null ? course.ccredit.toString() : '');
    final cpnoController = TextEditingController(text: course?.cpno);
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(course == null ? 'Add Course' : 'Edit Course'),
              content: SingleChildScrollView(
                child: IntrinsicWidth(
                  stepWidth: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: cnoController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Cno'),
                        style: const TextStyle(fontSize: 18),
                        readOnly: course != null,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cnameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Cname'),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ccreditController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Ccredit'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
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
                            style: Theme.of(context).textTheme.bodyMedium,
                            icon: const Icon(Icons.arrow_downward),
                            value: course?.cpno,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cpno'),
                            items: _courses.map((course) {
                              return DropdownMenuItem<String>(
                                value: course.cno,
                                child: Text(course.cname),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                cpnoController.text = value ?? '';
                              });
                            },
                          );
                        },
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
                    final cno = cnoController.text;
                    final cname = cnameController.text;
                    final ccredit = int.tryParse(ccreditController.text);
                    final cpno = cpnoController.text;

                    if (cno.isEmpty || cname.isEmpty || ccredit == null) {
                      setState(() {
                        errorMessage = 'All fields are required.';
                      });
                      return;
                    }

                    if (course == null) {
                      bool cnoExists =
                          _courses.any((course) => course.cno == cno);
                      if (cnoExists) {
                        setState(() {
                          errorMessage = 'Cno already exists';
                        });
                        return;
                      }
                    }

                    if (cpno.isNotEmpty &&
                        !_courses.any((course) => course.cno == cpno)) {
                      setState(() {
                        errorMessage = 'Invalid cpno';
                      });
                      return;
                    }

                    if (ccredit <= 1 || ccredit >= 8) {
                      setState(() {
                        errorMessage =
                            'Ccredit must be greater than 0.5 and less than 8.';
                      });
                      return;
                    }

                    if (course == null) {
                      final newCourse = Course(
                        cno: cno,
                        cname: cname,
                        ccredit: ccredit,
                        cpno: cpno,
                      );
                      await _databaseService.insertCourse(newCourse);
                      if (!mounted) return;
                      setState(() {
                        _courses.add(newCourse);
                        _filteredCourses = _courses;
                        _listKey.currentState?.insertItem(_courses.length - 1);
                      });
                    } else {
                      final updatedCourse = Course(
                        cno: cno,
                        cname: cname,
                        ccredit: ccredit,
                        cpno: cpno,
                      );
                      await _databaseService.updateCourse(updatedCourse);
                      if (!mounted) return;
                      setState(() {
                        final index = _courses.indexOf(course);
                        _courses[index] = updatedCourse;
                        _filteredCourses = _courses;
                      });
                    }

                    _refreshCourseList();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(course == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCourse(String cno) async {
    await _databaseService.deleteCourse(cno);
    final index = _courses.indexWhere((course) => course.cno == cno);
    final removedCourse = _courses.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedCourse, animation),
      duration: const Duration(milliseconds: 300),
    );
    _refreshCourseList();
  }

  Widget _buildItem(Course course, Animation<double> animation) {
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
            '${course.cno} - ${course.cname}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          subtitle: Text(
            'Credit: ${course.ccredit}, Cpno: ${course.cpno}',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
              course.cno.substring(0, 1),
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
                onPressed: () => _showForm(course: course),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => _deleteCourse(course.cno),
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
        title: const Text('Course Manager'),
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
              child: FutureBuilder<List<Course>>(
                future: _courseList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _filteredCourses.isNotEmpty
                      ? AnimatedList(
                          key: _listKey,
                          initialItemCount: _filteredCourses.length,
                          itemBuilder: (context, index, animation) {
                            if (index < 0 || index >= _filteredCourses.length) {
                              return Container(); // 返回一个空容器或者其他处理方式
                            }
                            return _buildItem(
                                _filteredCourses[index], animation);
                          },
                        )
                      : const Center(child: Text('No courses found'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        heroTag: "course_fab", // Add this line
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
