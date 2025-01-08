import 'package:flutter/material.dart';
import '../models/timer_record.dart';

class HistoryDialog extends StatelessWidget {
  final List<TimerRecord> records;

  const HistoryDialog({
    super.key,
    required this.records,
  });

  // 按天分组记录
  Map<String, List<TimerRecord>> _groupByDay() {
    final groups = <String, List<TimerRecord>>{};

    for (var record in records) {
      final date = record.startTime;
      final key = '${date.year}-${date.month}-${date.day}';

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(record);
    }

    return groups;
  }

  String _formatDate(String key) {
    final parts = key.split('-');
    return '${parts[1]}月${parts[2]}日';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final groupedRecords = _groupByDay();
    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade200,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Center(
                child: Text(
                  '历史记录',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedDates.map((date) {
                    final dayRecords = groupedRecords[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _formatDate(date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...dayRecords.map((record) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${record.duration}分钟',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatDuration(record.actualTime),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      record.completed ? '完成' : '中断',
                                      style: TextStyle(
                                        color: record.completed
                                            ? Colors.green[100]
                                            : Colors.red[200],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _formatTime(record.startTime),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(
                          color: Colors.white24,
                          height: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
