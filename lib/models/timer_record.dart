class TimerRecord {
  final DateTime startTime;
  final int duration; // 计划时长（分钟）
  final int actualTime; // 实际时长（秒）
  final bool completed;

  TimerRecord({
    required this.startTime,
    required this.duration,
    required this.actualTime,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'duration': duration,
        'actualTime': actualTime,
        'completed': completed,
      };

  factory TimerRecord.fromJson(Map<String, dynamic> json) => TimerRecord(
        startTime: DateTime.parse(json['startTime']),
        duration: json['duration'],
        actualTime: json['actualTime'] ?? json['duration'] * 60,
        completed: json['completed'],
      );
}
