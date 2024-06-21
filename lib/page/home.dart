import 'package:flutter/material.dart';
import 'sc_page.dart';
import 'student_page.dart';
import 'course_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  static final List<Widget> _widgetOptions = <Widget>[
    const StudentPage(),
    const CoursePage(),
    const SCPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'SC',
          ),
        ],
      ),
    );
  }
}
