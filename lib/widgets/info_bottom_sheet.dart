import 'package:flutter/material.dart';

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    ),
  );
}
