import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF076633); // Your theme color

    return Scaffold(
      body: navigationShell,
      
      bottomNavigationBar: BottomNavigationBar(
        // --- ADD THIS LINE ---
        type: BottomNavigationBarType.fixed, // Keeps style consistent with 4+ items
        
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],

        // --- UPDATED ITEMS LIST ---
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Agreement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled),
            label: 'Smart Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}