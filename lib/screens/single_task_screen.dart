import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SingleTaskScreen extends StatefulWidget {
  const SingleTaskScreen({super.key});

  @override
  State<SingleTaskScreen> createState() => _SingleTaskScreenState();
}

class _SingleTaskScreenState extends State<SingleTaskScreen> with WidgetsBindingObserver {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _duration = 25; // Default duration in minutes
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isPlaying = false;
  int _reflectionRating = 0;
  final TextEditingController _reflectionController = TextEditingController();
  bool _showReflection = false;

  // For tracking total tasks completed
  int _totalTasksCompleted = 0;

  // For Mid-Session Chimes
  Timer? _chimeTimer;
  int _chimeInterval = 5; // Chime every 5 minutes (adjust as needed)

  // For Focus Lock reminders
  bool _isAppInBackground = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _duration * 60;
    WidgetsBinding.instance.addObserver(this);
    _loadNotes(); // Load notes when the screen initializes
    _loadReflection(); // Load reflection data when the screen initializes
  }

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    _reflectionController.dispose();
    _timer?.cancel();
    _chimeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _isAppInBackground = true;
    } else if (state == AppLifecycleState.resumed && _isAppInBackground && _isPlaying) {
      _isAppInBackground = false;
      // Show a gentle reminder when the user returns to the app while the timer is running
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Come back to your task!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startTimer() {
    setState(() {
      _isPlaying = true;
      _showReflection = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          // Check for mid-session chime
          if (_secondsRemaining > 0 && (_duration * 60 - _secondsRemaining) % (_chimeInterval * 60) == 0) {
            _playChime(); // Implement chime sound playback
          }
        } else {
          _stopTimer();
          _showReflection = true;
          _incrementTasksCompleted(); // Increment completed tasks
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _chimeTimer?.cancel(); // Cancel chime timer when main timer stops
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = _duration * 60;
      _reflectionRating = 0;
      _reflectionController.clear();
      _showReflection = false;
    });
  }

  void _playChime() {
    // TODO: Implement chime sound playback
    print('Chime!'); // Placeholder for chime sound
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('single_task_notes', _notesController.text);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    _notesController.text = prefs.getString('single_task_notes') ?? '';
    _loadTasksCompleted(); // Load total tasks completed
  }

  Future<void> _saveReflection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('single_task_reflection_rating', _reflectionRating);
    await prefs.setString('single_task_reflection_text', _reflectionController.text);
  }

  Future<void> _loadReflection() async {
     final prefs = await SharedPreferences.getInstance();
     _reflectionRating = prefs.getInt('single_task_reflection_rating') ?? 0;
     _reflectionController.text = prefs.getString('single_task_reflection_text') ?? '';
  }

  Future<void> _incrementTasksCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    _totalTasksCompleted = (_totalTasksCompleted + 1);
    await prefs.setInt('total_single_tasks_completed', _totalTasksCompleted);
  }

   Future<void> _loadTasksCompleted() async {
     final prefs = await SharedPreferences.getInstance();
     setState(() {
       _totalTasksCompleted = prefs.getInt('total_single_tasks_completed') ?? 0;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoloMode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _duration = int.tryParse(value) ?? 25;
                          _secondsRemaining = _duration * 60;
                        });
                      },
                       controller: TextEditingController(text: _duration.toString()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isPlaying ? _stopTimer : _startTimer,
                    child: Text(_isPlaying ? 'Stop' : 'Start'),
                  ),
                  const SizedBox(width: 8),
                   IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _resetTimer,
                   ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Add Mid-Session Chimes toggle
              const SizedBox(height: 16),
              Text(
                'Quick Notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Jot down intrusive thoughts...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveNotes(), // Save notes as they are typed
              ),
              const SizedBox(height: 24),
              if (_showReflection) ...[
                Text(
                  'End-of-Session Reflection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        _reflectionRating > index ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _reflectionRating = index + 1;
                        });
                        _saveReflection();
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                 TextField(
                  controller: _reflectionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'How focused were you today?',
                    border: OutlineInputBorder(),
                  ),
                   onChanged: (_) => _saveReflection(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 