import 'package:flutter/material.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.current});

  final String current;

  static const options = ['기본순', '평점 높은순', '최신순'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '정렬',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          for (final option in options)
            ListTile(
              title: Text(option),
              trailing: option == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}