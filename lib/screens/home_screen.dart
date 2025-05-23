import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'pomodoro_screen.dart';
import 'meditation_screen.dart';
import 'deep_reading_screen.dart';
import 'motivation_screen.dart';
import 'single_task_screen.dart';
import 'digital_detox_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFreak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.setThemeMode(
                themeProvider.themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Focus Exercises',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildFeatureCard(
                  context,
                  'Pomodoro',
                  Icons.timer,
                  'Time management technique',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PomodoroScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  'Meditation',
                  Icons.self_improvement,
                  'Mindfulness practice',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MeditationScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  'Deep Reading',
                  Icons.menu_book,
                  'Immerse in literature',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeepReadingScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  'Daily Motivation',
                  Icons.format_quote,
                  'Get inspired every day',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MotivationScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  'Single Task',
                  Icons.check_circle_outline,
                  'One task at a time',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SingleTaskScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  'Digital Detox',
                  Icons.phone_android,
                  'Take a break from screens',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DigitalDetoxScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .scale(delay: const Duration(milliseconds: 200)),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }
} 