import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;
  int _selectedBreakDuration = 5; // Default short break duration
  int _selectedFocusDuration = 25; // Default focus duration
  final List<int> _breakDurations = [5, 15]; // Short break and long break options
  final List<int> _focusDurations = [15, 25, 30, 45]; // Focus duration options

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isBreak = !_isBreak;
            if (_isBreak) {
              _completedPomodoros++;
              // Use long break (15 min) after every 4 pomodoros
              _selectedBreakDuration = _completedPomodoros % 4 == 0 ? 15 : 5;
            }
            _remainingSeconds = _isBreak ? _selectedBreakDuration * 60 : _selectedFocusDuration * 60;
          }
        });
      });
      setState(() {
        _isRunning = true;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = _selectedFocusDuration * 60;
      _completedPomodoros = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildDurationSelector(String title, List<int> durations, int selectedDuration, Function(int) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: durations.map((duration) {
            return ChoiceChip(
              label: Text('$duration min'),
              selected: selectedDuration == duration,
              onSelected: (selected) {
                if (!_isRunning) {
                  onSelected(duration);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / (_isBreak ? _selectedBreakDuration * 60 : _selectedFocusDuration * 60);
    final color = _isBreak
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isBreak ? 'Break Time' : 'Focus Time'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRunning) ...[
              _buildDurationSelector(
                'Focus Duration',
                _focusDurations,
                _selectedFocusDuration,
                (duration) {
                  setState(() {
                    _selectedFocusDuration = duration;
                    if (!_isBreak) {
                      _remainingSeconds = duration * 60;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildDurationSelector(
                'Break Duration',
                _breakDurations,
                _selectedBreakDuration,
                (duration) {
                  setState(() {
                    _selectedBreakDuration = duration;
                    if (_isBreak) {
                      _remainingSeconds = duration * 60;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            CircularPercentIndicator(
              radius: 120,
              lineWidth: 12,
              percent: progress,
              progressColor: color,
              backgroundColor: color.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .scale(delay: const Duration(milliseconds: 200)),
                  Text(
                    _isBreak ? 'Break' : 'Focus',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                        ),
                  ),
                  if (!_isBreak) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Completed: $_completedPomodoros',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                          ),
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .scale(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _startTimer,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400))
                    .scale(),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _resetTimer,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.refresh),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600))
                    .scale(),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 