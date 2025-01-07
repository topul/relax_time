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
  static const int defaultDuration = 25 * 60; // 25分钟
  int _secondsRemaining = defaultDuration;
  Timer? _timer;
  bool _isRunning = false;

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
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Stack(
                children: [
                  // 关闭按钮
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
                          size: 20,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                      ),
                    ),
                  // 主要内容
                  Center(
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
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _resetTimer,
                              icon: const Icon(
                                Icons.refresh,
                                size: 28,
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
