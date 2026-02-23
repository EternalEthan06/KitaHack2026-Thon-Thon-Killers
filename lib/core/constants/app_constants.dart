class AppConstants {
  // SDG Goal Names
  static const List<String> sdgGoals = [
    'No Poverty',               // 1
    'Zero Hunger',              // 2
    'Good Health & Well-Being', // 3
    'Quality Education',        // 4
    'Gender Equality',          // 5
    'Clean Water & Sanitation', // 6
    'Affordable Clean Energy',  // 7
    'Decent Work & Economic Growth', // 8
    'Industry, Innovation & Infrastructure', // 9
    'Reduced Inequalities',     // 10
    'Sustainable Cities',       // 11
    'Responsible Consumption',  // 12
    'Climate Action',           // 13
    'Life Below Water',         // 14
    'Life on Land',             // 15
    'Peace, Justice & Institutions', // 16
    'Partnerships for the Goals', // 17
  ];

  static const List<String> sdgIcons = [
    '🏠', '🌾', '❤️', '📚', '⚧️', '💧',
    '⚡', '💼', '🏭', '⚖️', '🏙️', '♻️',
    '🌍', '🌊', '🌿', '🕊️', '🤝',
  ];

  // Scoring thresholds
  static const int streakBonusDays7 = 7;
  static const double streakMultiplier7 = 1.5;
  static const int streakBonusDays30 = 30;
  static const double streakMultiplier30 = 2.0;

  // Reward costs
  static const int rewardVoucherCost = 500;
  static const int rewardTreeCost = 300;
  static const int rewardBadgeCost = 100;

  // Firestore collections
  static const String colUsers = 'users';
  static const String colPosts = 'posts';
  static const String colRewards = 'rewards';
  static const String colNGOs = 'ngo_orgs';
  static const String colVolunteerEvents = 'volunteer_events';
  static const String colDonations = 'donations';
  static const String colProducts = 'marketplace_products';
  static const String colDiary = 'diary_entries';
}
