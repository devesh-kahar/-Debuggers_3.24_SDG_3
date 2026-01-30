import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/gamification.dart';
import '../../widgets/gamification_widgets.dart';
import '../../utils/theme.dart';

/// Gamification Screen - Shows badges, challenges, and achievements
class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PointsWidget(points: provider.totalPoints),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      _buildStatsRow(context, provider),
                      const SizedBox(height: 24),
                      
                      // Level Progress
                      LevelProgressWidget(
                        level: provider.level,
                        levelTitle: provider.levelTitle,
                        progress: provider.levelProgress,
                        totalPoints: provider.totalPoints,
                      ),
                      const SizedBox(height: 24),
                      
                      // Weekly Challenges
                      _buildSectionTitle(context, 'Weekly Challenges', '🎯'),
                      const SizedBox(height: 12),
                      ...provider.activeChallenges.map(
                        (challenge) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ChallengeCard(challenge: challenge),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Badges Section
                      _buildSectionTitle(context, 'Badges', '🏅'),
                      const SizedBox(height: 12),
                      _buildBadgesGrid(context, provider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, GamificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🔥', '${provider.currentStreak}', 'Day Streak'),
          Container(width: 1, height: 50, color: Colors.white30),
          _buildStatItem('⭐', 'Lv.${provider.level}', provider.levelTitle),
          Container(width: 1, height: 50, color: Colors.white30),
          _buildStatItem('🏆', '${provider.earnedBadges.length}', 'Badges'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid(BuildContext context, GamificationProvider provider) {
    final allBadges = provider.allBadgesWithStatus;
    
    // Group badges by category
    final Map<BadgeCategory, List<Badge>> badgesByCategory = {};
    for (final badge in allBadges) {
      badgesByCategory.putIfAbsent(badge.category, () => []);
      badgesByCategory[badge.category]!.add(badge);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: badgesByCategory.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _getCategoryName(entry.key),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final badge = entry.value[index];
                return GestureDetector(
                  onTap: () => _showBadgeDetails(context, badge),
                  child: Container(
                    decoration: BoxDecoration(
                      color: badge.isEarned 
                          ? _getTierColor(badge.tier).withOpacity(0.1) 
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: badge.isEarned 
                            ? _getTierColor(badge.tier) 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          badge.emoji,
                          style: TextStyle(
                            fontSize: 28,
                            color: badge.isEarned ? null : Colors.grey.shade400,
                          ),
                        ),
                        if (!badge.isEarned)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.gettingStarted:
        return 'Getting Started';
      case BadgeCategory.consistency:
        return 'Consistency';
      case BadgeCategory.health:
        return 'Health Tracking';
      case BadgeCategory.pregnancy:
        return 'Pregnancy Journey';
      case BadgeCategory.fertility:
        return 'Fertility Tracking';
      case BadgeCategory.community:
        return 'Community';
    }
  }

  Color _getTierColor(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:
        return Colors.brown.shade400;
      case BadgeTier.silver:
        return Colors.grey.shade500;
      case BadgeTier.gold:
        return Colors.amber.shade600;
      case BadgeTier.platinum:
        return Colors.purple.shade400;
    }
  }

  void _showBadgeDetails(BuildContext context, Badge badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: badge.isEarned 
                    ? _getTierColor(badge.tier).withOpacity(0.1) 
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.isEarned 
                      ? _getTierColor(badge.tier) 
                      : Colors.grey.shade300,
                  width: 3,
                ),
              ),
              child: Text(
                badge.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getTierColor(badge.tier).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.tier.displayName,
                style: TextStyle(
                  color: _getTierColor(badge.tier),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (badge.isEarned && badge.earnedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Earned on ${_formatDate(badge.earnedAt!)}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
            if (!badge.isEarned) ...[
              const SizedBox(height: 16),
              Text(
                '🔒 Complete the challenge to unlock!',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
