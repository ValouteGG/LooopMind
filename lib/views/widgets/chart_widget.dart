import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, int> studyTimeBySubject;

  const ChartWidget({Key? key, required this.studyTimeBySubject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: studyTimeBySubject.entries
              .map(
                (entry) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${entry.value} min'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: entry.value / 600,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
