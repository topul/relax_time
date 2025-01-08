import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _timer = null;
          _isRunning = false;
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
    setState(() {
      _isRunning = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (details) {
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Stack(
                children: [
                  if (Platform.isWindows)
                    Positioned(
                      right: 16,
                      top: 0,
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
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_secondsRemaining),
                          style: TextStyle(
                            fontSize: _showSettings ? 48 : 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_showSettings) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_selectedMinutes}分钟',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 160,
                                height: 20,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.red.shade300,
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.white.withOpacity(0.3),
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
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _isRunning ? _pauseTimer : _startTimer,
                              icon: Icon(
                                _isRunning ? Icons.pause : Icons.play_arrow,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                _resetTimer();
                                _showSettings = false;
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showSettings = !_showSettings;
                                });
                              },
                              icon: const Icon(
                                Icons.settings,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
