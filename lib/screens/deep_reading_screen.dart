import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DeepReadingScreen extends StatefulWidget {
  const DeepReadingScreen({super.key});

  @override
  State<DeepReadingScreen> createState() => _DeepReadingScreenState();
}

class _DeepReadingScreenState extends State<DeepReadingScreen> {
  bool _isReadingMode = false;
  bool _isDarkMode = false;
  Timer? _readingTimer;
  int _readingSeconds = 0;
  String _selectedBook = '';
  List<String> _bookmarks = [];
  final List<Map<String, String>> _books = [
    {
      'title': 'The Adventures of Sherlock Holmes',
      'author': 'Arthur Conan Doyle',
      'content': 'To Sherlock Holmes she is always the woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex. It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. He was, I take it, the most perfect reasoning and observing machine that the world has seen, but as a lover he would have placed himself in a false position. He never spoke of the softer passions, save with a gibe and a sneer. They were admirable things for the observer—excellent for drawing the veil from men\'s motives and actions. But for the trained reasoner to admit such intrusions into his own delicate and finely adjusted temperament was to introduce a distracting factor which might throw a doubt upon all his mental results. Grit in a sensitive instrument, or a crack in one of his own high-power lenses, would not be more disturbing than a strong emotion in a nature such as his. And yet there was but one woman to him, and that woman was the late Irene Adler, of dubious and questionable memory.',
    },
    {
      'title': 'Meditations',
      'author': 'Marcus Aurelius',
      'content': 'You have power over your mind - not outside events. Realize this, and you will find strength. The happiness of your life depends upon the quality of your thoughts. Everything we hear is an opinion, not a fact. Everything we see is a perspective, not the truth. Waste no more time arguing about what a good man should be. Be one. The best revenge is to be unlike him who performed the injury. If it is not right do not do it; if it is not true do not say it. The soul becomes dyed with the color of its thoughts. Very little is needed to make a happy life; it is all within yourself in your way of thinking.',
    },
    // Add more books here
  ];

  // For tracking listening time
  int _totalReadingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadTotalReadingTime();
    if (_books.isNotEmpty) {
      _selectedBook = _books[0]['title']!;
    }
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _saveTotalReadingTime(); // Save total reading time on dispose
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarks = prefs.getStringList('bookmarks_$_selectedBook') ?? [];
    });
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks_$_selectedBook', _bookmarks);
  }

  void _toggleReadingMode() {
    setState(() {
      _isReadingMode = !_isReadingMode;
      if (_isReadingMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        _startReadingTimer();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _readingTimer?.cancel();
      }
    });
  }

  void _startReadingTimer() {
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _readingSeconds++;
        _totalReadingSeconds++; // Increment total reading time
        if (_readingSeconds >= 600 && !_completedFirst10Min) {
          _completedFirst10Min = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Achievement Unlocked: First 10 Minutes!')),
          );
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _addBookmark() {
    if (_bookmarks.length < 10) {
      final selectedText = ''; // TODO: Implement text selection
      if (selectedText.isNotEmpty) {
        setState(() {
          _bookmarks.add(selectedText);
          _saveBookmarks();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 bookmarks allowed')),
      );
    }
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('Are you sure you want to reset your reading progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _readingSeconds = 0;
                _bookmarks.clear();
                _saveBookmarks();
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTotalReadingTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_reading_seconds', _totalReadingSeconds);
  }

  Future<void> _loadTotalReadingTime() async {
    final prefs = await SharedPreferences.getInstance();
    _totalReadingSeconds = prefs.getInt('total_reading_seconds') ?? 0;
  }

  // Achievements
  bool _completedFirst10Min = false;

  @override
  Widget build(BuildContext context) {
    if (_isReadingMode) {
      return _buildReadingMode();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Reading'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  title: Text(book['title']!),
                  subtitle: Text(book['author']!),
                  onTap: () {
                    setState(() {
                      _selectedBook = book['title']!;
                      _loadBookmarks();
                    });
                    _toggleReadingMode();
                  },
                );
              },
            ),
          ),
          if (_bookmarks.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookmarks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_bookmarks[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _bookmarks.removeAt(index);
                              _saveBookmarks();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetProgress,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildReadingMode() {
    final selectedBook = _books.firstWhere((book) => book['title'] == _selectedBook);
    
    return WillPopScope(
      onWillPop: () async {
        _toggleReadingMode();
        return false;
      },
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedBook['title']!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedBook['author']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    selectedBook['content']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _isDarkMode ? Colors.white : Colors.black,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: _isDarkMode ? Colors.black87 : Colors.white.withOpacity(0.87),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _toggleReadingMode,
                    ),
                    Text(
                      _formatTime(_readingSeconds),
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: _addBookmark,
                        ),
                        IconButton(
                          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 