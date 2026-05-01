import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderSelector extends StatelessWidget {
  final List<Folder> folders;
  final String? selectedFolderId; // null = All
  final ValueChanged<String?> onChanged;

  const FolderSelector({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(context, label: 'All', value: null),
          ...folders.map((f) => _chip(context, label: f.name, value: f.id)),
        ],
      ),
    );
  }

  Widget _chip(BuildContext c, {required String label, required String? value}) {
    final selected = selectedFolderId == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, letterSpacing: 0),
        ),
        selected: selected,
        onSelected: (_) => onChanged(value),
      ),
    );
  }
}
