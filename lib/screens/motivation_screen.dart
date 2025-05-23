import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final List<Map<String, String>> _quotes = [
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
    {
      'text': 'The key is not to prioritize what\'s on your schedule, but to schedule your priorities.',
      'author': 'Stephen Covey',
    },
    {
      'text': 'Concentrate all your thoughts upon the work in hand. The sun\'s rays do not burn until brought to a focus.',
      'author': 'Alexander Graham Bell',
    },
    {
      'text': 'Where focus goes, energy flows.',
      'author': 'Tony Robbins',
    },
    {
      'text': 'The successful warrior is the average man, with laser-like focus.',
      'author': 'Bruce Lee',
    },
    {
      'text': 'Focus on the journey, not the destination.',
      'author': 'Greg Anderson',
    },
    {
      'text': 'The main thing is to keep the main thing the main thing.',
      'author': 'Stephen Covey',
    },
    {
      'text': 'Focus on the present moment and make it beautiful.',
      'author': 'Unknown',
    },
    {
      'text': 'The difference between successful people and very successful people is that very successful people say no to almost everything.',
      'author': 'Warren Buffett',
    },
    {
      'text': 'Your time is limited, don\'t waste it living someone else\'s life.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt',
    },
    {
      'text': 'The best way to predict the future is to create it.',
      'author': 'Abraham Lincoln',
    },
    {
      'text': 'Innovation distinguishes between a leader and a follower.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Stay hungry, stay foolish.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'The only limit to our realization of tomorrow will be our doubts of today.',
      'author': 'Franklin D. Roosevelt',
    },
    {
      'text': 'It is during our darkest moments that we must focus to see the light.',
      'author': 'Aristotle Onassis',
    },
    {
      'text': 'Do not wait for the perfect time, start now.',
      'author': 'Unknown',
    },
    {
      'text': 'The mind is everything. What you think you become.',
      'author': 'Buddha',
    },
    {
      'text': 'The best and most beautiful things in the world cannot be seen or even heard - they must be felt with the heart.',
      'author': 'Helen Keller',
    },
    {
      'text': 'Live as if you were to die tomorrow. Learn as if you were to live forever.',
      'author': 'Mahatma Gandhi',
    },
    {
      'text': 'If you look at what you have in life, you\'ll always have more. If you look at what you don\'t have in life, you\'ll never have enough.',
      'author': 'Oprah Winfrey',
    },
    {
      'text': 'The most difficult thing is the decision to act, the rest is merely tenacity.',
      'author': 'Amelia Earhart',
    },
    {
      'text': 'Every strike brings me closer to the next home run.',
      'author': 'Babe Ruth',
    },
    {
      'text': 'Definiteness of purpose is the starting point of all achievement.',
      'author': 'W. Clement Stone',
    },
    {
      'text': 'We must let go of the life we have planned, so as to accept the one that is waiting for us.',
      'author': 'Joseph Campbell',
    },
    {
      'text': 'Nothing is impossible, the word itself says \'I\'m possible\'!',
      'author': 'Audrey Hepburn',
    },
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Light tomorrow with today!',
      'author': 'Elizabeth Barrett Browning',
    },
    {
      'text': 'The power of imagination makes us infinite.',
      'author': 'John Muir',
    },
  ];

  late String _currentQuote = '';
  late String _currentAuthor = '';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _selectQuote();
  }

  Future<void> _selectQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateString = prefs.getString('last_quote_date');
    final now = DateTime.now();
    DateTime? lastQuoteDate;
    if (lastDateString != null) {
      lastQuoteDate = DateTime.parse(lastDateString);
    }

    // Check if it's a new day or if no quote was saved for today
    if (lastQuoteDate == null ||
        lastQuoteDate.year != now.year ||
        lastQuoteDate.month != now.month ||
        lastQuoteDate.day != now.day) {
      // New day, select a new quote based on the day of the month
      final quoteIndex = now.day % _quotes.length;
      final quote = _quotes[quoteIndex];

      setState(() {
        _currentQuote = quote['text']!;
        _currentAuthor = quote['author']!;
      });

      // Save the selected quote and the date
      await prefs.setString('saved_quote', _currentQuote);
      await prefs.setString('saved_author', _currentAuthor);
      await prefs.setString('last_quote_date', now.toIso8601String());

    } else {
      // Same day, load the saved quote
      final savedQuote = prefs.getString('saved_quote');
      final savedAuthor = prefs.getString('saved_author');
      if (savedQuote != null && savedAuthor != null) {
        setState(() {
          _currentQuote = savedQuote;
          _currentAuthor = savedAuthor;
        });
      } else {
        // Fallback: If somehow no saved quote for today, select one based on day
         final quoteIndex = now.day % _quotes.length;
         final quote = _quotes[quoteIndex];
         setState(() {
          _currentQuote = quote['text']!;
          _currentAuthor = quote['author']!;
        });
         await prefs.setString('saved_quote', _currentQuote);
         await prefs.setString('saved_author', _currentAuthor);
         await prefs.setString('last_quote_date', now.toIso8601String());
      }
    }

    // Load favorite status for the current quote
    final isFavorite = prefs.getBool('quote_favorite_${_currentQuote.hashCode}') ?? false;
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await prefs.setBool('quote_favorite_${_currentQuote.hashCode}', _isFavorite);
  }

  Future<void> _shareQuote() async {
    // TODO: Implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQuote,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.format_quote,
                  size: 48,
                  color: Colors.grey,
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .scale(delay: const Duration(milliseconds: 200)),
                const SizedBox(height: 24),
                Text(
                  _currentQuote,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 24),
                Text(
                  '— $_currentAuthor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 1000))
                    .slideX(begin: 0.3, end: 0),
                const SizedBox(height: 48),
                Text(
                  'New quote every day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 