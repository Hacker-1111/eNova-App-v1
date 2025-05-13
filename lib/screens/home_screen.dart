import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notes_screen.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _noteCount = 0;
  int _taskCount = 0;
  int _priorityCount = 0;
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadCountsAndActivities();
  }

  Future<void> _loadCountsAndActivities() async {
    final notesSnapshot =
        await FirebaseFirestore.instance
            .collection('notes')
            .where('userId', isEqualTo: _user?.uid)
            .get();

    final tasksSnapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: _user?.uid)
            .get();

    int favoriteNotesCount = 0;
    int favoriteTasksCount = 0;
    List<Map<String, dynamic>> activities = [];

    for (var doc in notesSnapshot.docs) {
      final data = doc.data();
      if (data['favorite'] == true) favoriteNotesCount++;
      activities.add({
        ...data,
        'type': 'note',
        'docId': doc.id,
        'createdAt': data['createdAt'],
      });
    }

    for (var doc in tasksSnapshot.docs) {
      final data = doc.data();
      if (data['favorite'] == true) favoriteTasksCount++;
      activities.add({
        ...data,
        'type': 'task',
        'docId': doc.id,
        'createdAt': data['createdAt'],
      });
    }

    // ترتيب الأنشطة حسب التاريخ
    activities.sort((a, b) {
      final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    setState(() {
      _noteCount = notesSnapshot.size;
      _taskCount = tasksSnapshot.size;
      _priorityCount =
          favoriteNotesCount + favoriteTasksCount; // حساب الأولويات
      _recentActivities = activities.take(10).toList();
    });
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const NotesScreen();
      case 2:
        return const TasksScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomePage();
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Notes';
      case 2:
        return 'Tasks';
      case 3:
        return 'Profile';
      default:
        return 'App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCountsAndActivities,
        child: _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildStatsSection()),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: _buildLastActivitySection(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.indigo.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${_user?.displayName ?? 'User'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What would you like to do today?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildSearchBox(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged:
            (value) => setState(() => _searchQuery = value.toLowerCase()),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search notes or tasks...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.note, 'Notes', _noteCount),
          _buildStatItem(Icons.task, 'Tasks', _taskCount),
          _buildStatItem(Icons.star, 'Priority', _priorityCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, int count) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 30),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLastActivitySection() {
    final filtered =
        _recentActivities.where((item) {
          final title = item['title']?.toString().toLowerCase() ?? '';
          return title.contains(_searchQuery);
        }).toList();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: const [
              SizedBox(height: 60),
              Icon(Icons.note_alt_outlined, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No recent activities found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final activity = filtered[index];
        final isFavorite = activity['favorite'] == true;
        final isNote = activity['type'] == 'note';

        return GestureDetector(
          onTap: () => _viewActivity(activity),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(child: Text(activity['title'] ?? '')),
                  if (isFavorite)
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              ),
              subtitle: Text(activity['category'] ?? ''),
              leading: Icon(isNote ? Icons.note : Icons.task),
            ),
          ),
        );
      }, childCount: filtered.length),
    );
  }

  Future<void> _viewActivity(Map<String, dynamic> activity) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(activity: activity),
      ),
    );
  }
}

class ActivityDetailScreen extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isNote = activity['type'] == 'note';
    final title = activity['title'] ?? '';
    final content = activity['content'] ?? '';
    final category = activity['category'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(isNote ? 'Note Details' : 'Task Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
