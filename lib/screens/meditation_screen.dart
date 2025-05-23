import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedDuration = 5;
  String _selectedSound = 'None';
  String _selectedType = 'Guided Breathing';
  bool _isPlaying = false;
  Timer? _meditationTimer;

  final List<int> _durations = [1, 3, 5, 10, 15, 20];
  final List<String> _sounds = [
    'None',
    'Rain',
    'Ocean',
    'Forest',
    'White Noise',
    'Tibetan Bowls'
  ];
  final List<String> _types = [
    'Guided Breathing',
    'Body Scan',
    'Thought Observation',
    'Gratitude Meditation'
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      debugPrint('Audio player initialized');
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _meditationTimer?.cancel();
    super.dispose();
  }

  Future<void> _playSound() async {
    if (_selectedSound == 'None') {
      await _audioPlayer.stop();
      return;
    }

    try {
      String soundPath = 'assets/sounds/${_selectedSound.toLowerCase().replaceAll(' ', '_')}.mp3';
      debugPrint('Attempting to play sound: $soundPath');
      
      // First stop any existing playback
      await _audioPlayer.stop();
      
      // Set the source
      await _audioPlayer.setSource(AssetSource(soundPath));
      debugPrint('Source set successfully');
      
      // Set volume and release mode
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      debugPrint('Volume and release mode set');
      
      // Start playback
      await _audioPlayer.resume();
      debugPrint('Playback started');
      
      // Add listener for state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        debugPrint('Player state changed: $state');
      });
      
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _startMeditation() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      await _playSound();
      _meditationTimer = Timer(Duration(minutes: _selectedDuration), () {
        setState(() {
          _isPlaying = false;
        });
        _audioPlayer.stop();
      });
    } else {
      _meditationTimer?.cancel();
      await _audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Stillness'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Duration',
              Wrap(
                spacing: 8,
                children: _durations.map((duration) {
                  return ChoiceChip(
                    label: Text('$duration min'),
                    selected: _selectedDuration == duration,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Sound',
              Wrap(
                spacing: 8,
                children: _sounds.map((sound) {
                  return ChoiceChip(
                    label: Text(sound),
                    selected: _selectedSound == sound,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSound = sound;
                      });
                      if (_isPlaying) {
                        _playSound();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Meditation Type',
              Wrap(
                spacing: 8,
                children: _types.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale(
                        duration: const Duration(seconds: 4),
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                      )
                      .then()
                      .scale(
                        duration: const Duration(seconds: 4),
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(0.8, 0.8),
                      ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startMeditation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(_isPlaying ? 'Pause' : 'Start Meditation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
} 