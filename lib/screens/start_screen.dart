import 'package:flutter/material.dart';

import '../widgets/movielog_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry; // null이면 확인 중, 있으면 확인 실패 → 재시도

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.movie, size: 80, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'MovieLog',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text('나만의 영화 기록을 시작해보세요'),
              const Spacer(),
              if (onRetry == null)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    Text(message ?? '로그인 상태를 확인하지 못했어요.'),
                    const SizedBox(height: 12),
                    MovieLogButton(
                      label: '다시 시도',
                      width: double.infinity,
                      onPressed: onRetry,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}