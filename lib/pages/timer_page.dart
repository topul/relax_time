import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import '../models/timer_record.dart';
import '../widgets/history_dialog.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const int defaultDuration = 25 * 60;
  static const int minMinutes = 1; // 最小1分钟
  static const int maxMinutes = 120; // 最大120分钟
  int _selectedMinutes = 25;
  int _secondsRemaining = defaultDuration;
  Timer? _timer;
  bool _isRunning = false;
  bool _showSettings = false;
  bool _showHistory = false;
  DateTime? _currentStartTime;
  List<TimerRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('timer_history') ?? [];
    setState(() {
      _history = historyJson
          .map((json) =>
              TimerRecord.fromJson(Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _history.map((record) => jsonEncode(record.toJson())).toList();
    await prefs.setStringList('timer_history', historyJson);
  }

  void _startTimer() {
    if (_timer != null) return;

    _currentStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _addToHistory(true);
          _timer?.cancel();
          _timer = null;
          _isRunning = false;
          _currentStartTime = null;
        }
      });
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _addToHistory(false);
    setState(() {
      _isRunning = false;
      _currentStartTime = null;
    });
  }

  void _addToHistory(bool completed) {
    if (_currentStartTime != null) {
      final actualTime = _selectedMinutes * 60 - _secondsRemaining; // 计算实际时长
      final record = TimerRecord(
        startTime: _currentStartTime!,
        duration: _selectedMinutes,
        actualTime: actualTime,
        completed: completed,
      );
      setState(() {
        _history.insert(0, record);
        if (_history.length > 10) {
          _history.removeLast();
        }
      });
      _saveHistory();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _secondsRemaining = defaultDuration;
      _isRunning = false;
    });
  }

  void _setTimer(int minutes) {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (details) {
          // 获取设置面板的位置和大小
          if (_showSettings) {
            final settingsPanelRect = Rect.fromLTWH(
              16, // left padding
              0, // 从顶部开始
              224, // width (200 + 24 padding)
              MediaQuery.of(context).size.height, // 整个窗口高度
            );

            // 如果点击在设置面板内，不触发窗口拖动
            if (settingsPanelRect.contains(details.globalPosition)) {
              return;
            }
          }
          windowManager.startDragging();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade200,
                Colors.red.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // 主要内容（倒计时和控制按钮）
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                            icon: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              size: 32,
                              color: Colors.white,
                            ),
                            iconSize: 32,
                            splashRadius: 32,
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () {
                              _resetTimer();
                              _showSettings = false;
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 32,
                              color: Colors.white,
                            ),
                            iconSize: 32,
                            splashRadius: 32,
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showSettings = !_showSettings;
                              });
                            },
                            icon: const Icon(
                              Icons.settings,
                              size: 24,
                              color: Colors.white70,
                            ),
                            splashRadius: 24,
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () {
                              if (_history.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      HistoryDialog(records: _history),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.history,
                              size: 24,
                              color: Colors.white70,
                            ),
                            splashRadius: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 关闭按钮
              if (Platform.isWindows)
                Positioned(
                  right: 16,
                  top: 4,
                  child: IconButton(
                    onPressed: () {
                      windowManager.close();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 12,
                  ),
                ),
              // 设置面板和蒙层（放在最后，确保显示在最上层）
              if (_showSettings)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // 半透明蒙层
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showSettings = false;
                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                      // 设置面板
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '设置时长: ${_selectedMinutes}分钟',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 240,
                                height: 32,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.red.shade300,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                      pressedElevation: 8,
                                    ),
                                    overlayColor: Colors.white.withOpacity(0.3),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16,
                                    ),
                                    valueIndicatorColor: Colors.white,
                                    trackHeight: 2,
                                    valueIndicatorTextStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _selectedMinutes.toDouble(),
                                    min: minMinutes.toDouble(),
                                    max: maxMinutes.toDouble(),
                                    divisions: maxMinutes - minMinutes,
                                    label: '${_selectedMinutes}分钟',
                                    onChanged: (value) {
                                      _setTimer(value.round());
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
