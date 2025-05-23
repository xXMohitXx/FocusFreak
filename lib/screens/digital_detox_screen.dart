import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class DigitalDetoxScreen extends StatefulWidget {
  const DigitalDetoxScreen({super.key});

  @override
  State<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends State<DigitalDetoxScreen> with WidgetsBindingObserver {
  int _detoxDuration = 10; // Default duration in minutes
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isDetoxBroken = false;

  // For tracking total detox time
  int _totalDetoxSeconds = 0;

  final List<String> _motivationalQuotes = [
    'Unplug to recharge.',
    'Find peace in stillness.',
    'Be present, not online.',
    'Your mind needs a break.',
    'Connect with the real world.',
    'Digital silence, inner peace.',
    'Less screen, more life.',
    'Embrace the quiet.',
    'Focus on what truly matters.',
    'Freedom from the digital noise.',
  ]; // Add more quotes later

  String _currentQuote = '';
  Timer? _quoteTimer;

  // Achievements
  bool _completedFirst10Min = false;
  int _detoxStreak = 0;
  bool _completedHourLong = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _detoxDuration * 60;
    WidgetsBinding.instance.addObserver(this);
    _checkDetoxBrokenStatus();
    _loadAchievements();
    _loadTotalDetoxTime(); // Load total detox time
    _selectRandomQuote();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _saveDetoxStatus(); // Save detox status when leaving the screen
    _saveTotalDetoxTime(); // Save total detox time on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isPlaying) {
      if (state == AppLifecycleState.paused) {
        _isDetoxBroken = true;
        _saveDetoxStatus();
      } else if (state == AppLifecycleState.resumed && _isDetoxBroken) {
        _stopTimer();
        _showDetoxBrokenMessage();
      }
    }
  }

  Future<void> _saveDetoxStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_detox_broken', _isDetoxBroken);
    if (_isPlaying) {
      // Optionally save remaining time if needed for future resume feature
    }
  }

  Future<void> _checkDetoxBrokenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isDetoxBroken = prefs.getBool('is_detox_broken') ?? false;
    if (_isDetoxBroken) {
      _showDetoxBrokenMessage();
    }
  }

  void _showDetoxBrokenMessage() {
    // Clear the broken status after showing the message
    _isDetoxBroken = false;
    _saveDetoxStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detox broken! Stay focused next time.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _isPlaying = true;
      _isDetoxBroken = false; // Reset broken status on new start
      _secondsRemaining = _detoxDuration * 60; // Reset timer
    });
    _saveDetoxStatus(); // Save initial status
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          _totalDetoxSeconds++; // Increment total detox time
        } else {
          _stopTimer();
          _checkAchievements();
          _showCompletionMessage();
        }
      });
    });
    _startQuoteTimer();
  }

  void _stopTimer() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _quoteTimer?.cancel();
    _saveDetoxStatus(); // Save final status
    _saveTotalDetoxTime(); // Save total detox time
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = _detoxDuration * 60;
    });
    _isDetoxBroken = false; // Reset broken status on reset
    _saveDetoxStatus();
  }

  void _startQuoteTimer() {
    // Display a new quote every few minutes
    _quoteTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _selectRandomQuote();
    });
  }

  void _selectRandomQuote() {
    final random = Random();
    setState(() {
      _currentQuote = _motivationalQuotes[random.nextInt(_motivationalQuotes.length)];
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedFirst10Min = prefs.getBool('completed_first_10_min_detox') ?? false;
      _detoxStreak = prefs.getInt('detox_streak') ?? 0;
      _completedHourLong = prefs.getBool('completed_hour_long_detox') ?? false;
    });
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completed_first_10_min_detox', _completedFirst10Min);
    await prefs.setInt('detox_streak', _detoxStreak);
    await prefs.setBool('completed_hour_long_detox', _completedHourLong);
  }

  Future<void> _saveTotalDetoxTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_detox_seconds', _totalDetoxSeconds);
  }

  Future<void> _loadTotalDetoxTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalDetoxSeconds = prefs.getInt('total_detox_seconds') ?? 0;
    });
  }

  void _checkAchievements() {
    if (_detoxDuration >= 10 && !_completedFirst10Min) {
      _completedFirst10Min = true;
      _showAchievementMessage('First 10-minute detox completed!');
    }
    if (_detoxDuration >= 60 && !_completedHourLong) {
      _completedHourLong = true;
      _showAchievementMessage('Hour-long detox completed!');
    }
    // Streak logic requires more complex date tracking, will add a placeholder for now
    _detoxStreak++; // Simple streak increment for now
    _showAchievementMessage('Detox streak: $_detoxStreak days!');

    _saveAchievements();
  }

  void _showAchievementMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detox session completed!'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unplug Ritual'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPlaying) ...[
              Text(
                'Set Your Detox Goal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: _detoxDuration,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10 minutes')),
                  DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  DropdownMenuItem(value: 20, child: Text('20 minutes')),
                  DropdownMenuItem(value: 25, child: Text('25 minutes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem(value: 45, child: Text('45 minutes')),
                  DropdownMenuItem(value: 60, child: Text('60 minutes')),
                  DropdownMenuItem(value: 90, child: Text('90 minutes')),
                  DropdownMenuItem(value: 120, child: Text('120 minutes')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _detoxDuration = value;
                      _secondsRemaining = _detoxDuration * 60;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startTimer,
                child: const Text('Start Detox'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetTimer,
              ),
            ] else ...[
              Text(
                'Time Remaining',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                _formatTime(_secondsRemaining),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 24),
              Text(
                _currentQuote,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _stopTimer,
                child: const Text('End Detox'),
              ),
            ],
            const SizedBox(height: 40),
            Text(
              'Milestone Trophies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ListTile(
                  leading: Icon(
                    _completedFirst10Min ? Icons.military_tech : Icons.military_tech_outlined,
                    color: _completedFirst10Min ? Colors.amber : Colors.grey,
                  ),
                  title: const Text('First 10-minute Detox'),
                ),
                ListTile(
                  leading: Icon(
                    _completedHourLong ? Icons.military_tech : Icons.military_tech_outlined,
                    color: _completedHourLong ? Colors.amber : Colors.grey,
                  ),
                  title: const Text('Hour-long Detox'),
                ),
                ListTile(
                  leading: Icon(
                    _detoxStreak >= 7 ? Icons.military_tech : Icons.military_tech_outlined,
                    color: _detoxStreak >= 7 ? Colors.amber : Colors.grey,
                  ),
                  title: Text('7-day Streak (Current Streak: $_detoxStreak)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 