import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review_card.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _reviewedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<EducationProvider>(
      builder: (context, provider, child) {
        final dueCards = provider.dueCards;

        if (dueCards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Review Session')),
            body: const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'All caught up!',
              subtitle:
                  'No cards due for review today. Come back tomorrow for your next session.',
            ),
          );
        }

        if (_currentIndex >= dueCards.length) {
          return _buildSessionComplete(context, dueCards.length);
        }

        final card = dueCards[_currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Review  ${_currentIndex + 1} / ${dueCards.length}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'End Session',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildProgressBar(dueCards.length),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _isFlipped = !_isFlipped),
                          child: _buildCard(card),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_isFlipped)
                        _buildRevealHint()
                      else
                        _buildRatingButtons(context, provider, card),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(int total) {
    return LinearProgressIndicator(
      value: _currentIndex / total,
      backgroundColor: Colors.grey.shade200,
      color: AppTheme.primaryColor,
      minHeight: 4,
    );
  }

  Widget _buildCard(ReviewCard card) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_isFlipped ? 'back' : 'front'),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isFlipped ? 'Answer' : 'Question',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isFlipped
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isFlipped ? card.back : card.front,
                style: const TextStyle(fontSize: 20, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (!_isFlipped) ...[
                const SizedBox(height: 32),
                const Icon(
                  Icons.touch_app,
                  color: Colors.grey,
                  size: 20,
                ),
                const Text(
                  'Tap to reveal answer',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevealHint() {
    return OutlinedButton.icon(
      onPressed: () => setState(() => _isFlipped = true),
      icon: const Icon(Icons.visibility),
      label: const Text('Show Answer'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      ),
    );
  }

  Widget _buildRatingButtons(
    BuildContext context,
    EducationProvider provider,
    ReviewCard card,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How well did you remember?',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _RatingButton(
              label: 'Again',
              sublabel: '< 10 min',
              color: AppTheme.errorColor,
              onTap: () => _rate(context, provider, card, ReviewRating.again),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Hard',
              sublabel: '< 1 day',
              color: AppTheme.warningColor,
              onTap: () => _rate(context, provider, card, ReviewRating.hard),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Good',
              sublabel: _intervalLabel(card, ReviewRating.good),
              color: AppTheme.primaryColor,
              onTap: () => _rate(context, provider, card, ReviewRating.good),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Easy',
              sublabel: _intervalLabel(card, ReviewRating.easy),
              color: AppTheme.successColor,
              onTap: () => _rate(context, provider, card, ReviewRating.easy),
            ),
          ],
        ),
      ],
    );
  }

  String _intervalLabel(ReviewCard card, ReviewRating rating) {
    // Estimate next interval for display
    switch (rating) {
      case ReviewRating.again:
        return '1d';
      case ReviewRating.hard:
        return '1d';
      case ReviewRating.good:
        if (card.repetitionCount == 0) return '1d';
        if (card.repetitionCount == 1) return '6d';
        return '${(card.intervalDays * card.easeFactor).round()}d';
      case ReviewRating.easy:
        if (card.repetitionCount == 0) return '1d';
        return '${(card.intervalDays * (card.easeFactor + 0.15)).round()}d';
    }
  }

  void _rate(
    BuildContext context,
    EducationProvider provider,
    ReviewCard card,
    ReviewRating rating,
  ) {
    provider.recordReview(card.id, rating);
    setState(() {
      _currentIndex++;
      _isFlipped = false;
      _reviewedCount++;
    });
  }

  Widget _buildSessionComplete(BuildContext context, int total) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 48,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Session Complete!', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'You reviewed $_reviewedCount card${_reviewedCount == 1 ? '' : 's'}.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
