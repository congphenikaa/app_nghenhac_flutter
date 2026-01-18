import 'package:app_nghenhac/src/views/MiniPlayer.dart';
import 'package:app_nghenhac/src/views/home_screen.dart';
import 'package:app_nghenhac/src/views/library_screen.dart';
import 'package:app_nghenhac/src/views/premium_screen.dart';
import 'package:app_nghenhac/src/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Key để quản lý Navigator cho từng tab
  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex]
        .currentState!
        .maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_currentIndex != 0) {
        setState(() => _currentIndex = 0);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // LỚP 1: Nội dung các tab (Nested Navigators)
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),

            // LỚP 2: MiniPlayer (Nằm trên nội dung, dưới BottomNav)
            const Positioned(bottom: 0, left: 0, right: 0, child: MiniPlayer()),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(
            context,
          ).copyWith(canvasColor: const Color(0xFF112117)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_currentIndex == index) {
                // Nếu bấm lại tab hiện tại -> quay về trang đầu của tab đó
                _navigatorKeys[index].currentState?.popUntil(
                  (route) => route.isFirst,
                );
              } else {
                setState(() => _currentIndex = index);
              }
            },
            backgroundColor: const Color(0xFF112117).withOpacity(0.95),
            selectedItemColor: const Color(0xFF30e87a),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: "Library",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium),
                label: "Premium",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo Navigator riêng cho từng tab
  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (index) {
                case 0:
                  return const HomeScreen();
                case 1:
                  return const SearchScreen();
                case 2:
                  return const LibraryScreen();
                case 3:
                  return const PremiumScreen();
                default:
                  return const HomeScreen();
              }
            },
          );
        },
      ),
    );
  }
}
