import 'package:flutter/material.dart';
import 'shopping_list_page.dart';
import 'categories_page.dart';
import 'summary_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationPage(),
        '/shopping-list': (context) => const ShoppingListPage(),
        '/categories': (context) => const CategoriesPage(),
        '/summary': (context) => const SummaryPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ShoppingListPage(),
    CategoriesPage(),
    SummaryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Summary'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
