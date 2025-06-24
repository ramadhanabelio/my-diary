import 'package:flutter/material.dart';
import '../constants/theme.dart' show AppGradients;
import '../services/api.dart';
import '../models/user.dart';
import '../models/diary.dart';
import 'login.dart';
import 'create.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  List<Diary> _diaries = [];
  List<Diary> _filteredDiaries = [];
  bool _isLoadingUser = true;
  bool _isLoadingDiaries = true;
  bool _hasDiaryError = false;

  String _searchQuery = '';
  DateTime? _selectedDate;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDiaries();
  }

  Future<void> _loadUser() async {
    try {
      final user = await ApiService.getUser();
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (_) {
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _loadDiaries() async {
    setState(() {
      _isLoadingDiaries = true;
      _hasDiaryError = false;
    });

    try {
      final diaries = await ApiService.getDiaries();
      setState(() {
        _diaries = diaries;
        _isLoadingDiaries = false;
      });
      _applyFilters();
    } catch (_) {
      setState(() {
        _isLoadingDiaries = false;
        _hasDiaryError = true;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDiaries =
          _diaries.where((diary) {
            final matchSearch =
                diary.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                diary.content.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );

            final matchDate =
                _selectedDate == null ||
                diary.date == _selectedDate!.toIso8601String().substring(0, 10);

            return matchSearch && matchDate;
          }).toList();
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah kamu yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _navigateToCreateDiary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePage()),
    );

    if (result == true) await _loadDiaries();
  }

  void _navigateToDetail(Diary diary) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(diary: diary)),
    );

    if (result == true) await _loadDiaries();
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.mainGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang,',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _user?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(Diary diary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Diary'),
            content: const Text('Apakah kamu yakin ingin menghapus diary ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final result = await ApiService.deleteDiary(diary.id);
      if (result['success']) {
        await _loadDiaries();
        if (!mounted) return false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Diary berhasil dihapus')));
        return true;
      } else {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menghapus diary')),
        );
        return false;
      }
    }

    return false;
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                labelText: 'Pencarian...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.mainGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.date_range, color: Colors.white),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                  _applyFilters();
                }
              },
            ),
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() => _selectedDate = null);
                _applyFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDiarySection() {
    if (_isLoadingDiaries) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasDiaryError) {
      return const Center(
        child: Text(
          'Gagal memuat data diary',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    if (_filteredDiaries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tidak ada diary yang cocok dengan pencarian atau filter.',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _filteredDiaries.length,
      itemBuilder: (context, index) {
        final diary = _filteredDiaries[index];
        return Dismissible(
          key: Key(diary.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(diary),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () => _navigateToDetail(diary),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.mainGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      diary.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      diary.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDiaries,
              child: _buildDiarySection(),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.mainGradient,
        ),
        child: FloatingActionButton(
          onPressed: _navigateToCreateDiary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
