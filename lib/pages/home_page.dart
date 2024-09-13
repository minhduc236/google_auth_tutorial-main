import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.lightBlue.shade100,
                width: 2,
              ),
            ),
          ),
          child: AppBar(
            title: const Text('Hi!'),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.lightBlue.shade100,
                width: 2,
              ),
            ),
          ),
          child: const AppDrawer(),
        ),
      ),
      body: const BottomNavigation(),
    );
  }
}
