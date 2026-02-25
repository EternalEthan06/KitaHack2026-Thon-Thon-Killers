class DailyTaskModel {
  final String id;
  final String title;
  final String description;
  final List<int> sdgGoals;
  final int points;
  final String difficulty; // Easy, Medium, Hard
  final bool isCompleted;
  final DateTime date;

  DailyTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sdgGoals,
    required this.points,
    required this.difficulty,
    this.isCompleted = false,
    required this.date,
  });

  factory DailyTaskModel.fromMap(Map<dynamic, dynamic> data, String id) {
    return DailyTaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      sdgGoals: List<int>.from(data['sdgGoals'] ?? []),
      points: data['points'] ?? 0,
      difficulty: data['difficulty'] ?? 'Easy',
      isCompleted: data['isCompleted'] ?? false,
      date: data['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'sdgGoals': sdgGoals,
        'points': points,
        'difficulty': difficulty,
        'isCompleted': isCompleted,
        'date': date.millisecondsSinceEpoch,
      };
}
