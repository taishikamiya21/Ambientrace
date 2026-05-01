import 'package:flutter/material.dart';

enum ProviderState { active, configured, notSet }

class AiProviderBadge extends StatelessWidget {
  final ProviderState state;

  const AiProviderBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (state) {
      ProviderState.active => ('Active', Colors.greenAccent),
      ProviderState.configured => ('Configured', Colors.blueAccent),
      ProviderState.notSet => ('Not Set', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, letterSpacing: 1),
      ),
    );
  }
}
