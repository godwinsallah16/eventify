import 'package:eventify/core/app_export.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Ensure HomeScreen is included
    const CalendarScreen(),
    const BookmarkScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.cyan, // Match this with the app bar color
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: const Text(
            'Eventify',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF55CDF3),
          leading: IconButton(
            icon: const Icon(Icons.format_list_bulleted_outlined,
                color: Colors.black),
            onPressed: () {
              Drawer(
                child: ListView(
                  children: const [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(0xFF55CDF3),
                      ),
                      child: Text('Drawer Header'),
                    ),
                    ListTile(
                      title: Text('Item 1'),
                      onTap: null,
                    ),
                    ListTile(
                      title: Text('Item 2'),
                      onTap: null,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: const [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: null,
            ),
          ],
          elevation: 0, // Remove the shadow
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _widgetOptions,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          icons: const [
            Icons.home_outlined,
            Icons.calendar_today_outlined,
            Icons.bookmark_outline_outlined,
            Icons.person,
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding:
              const EdgeInsets.only(bottom: kBottomNavigationBarHeight - 56),
          child: FloatingActionButton(
            onPressed: () async {
              NavigatorService.pushNamed(AppRoutes.eventForm);
            },
            backgroundColor: const Color(0xFF55CDF3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

// Placeholder widget classes for each tab

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Calendar Screen'));
  }
}

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bookmark Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}
