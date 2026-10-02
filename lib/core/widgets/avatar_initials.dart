import 'package:flutter/material.dart';

/// Circle with the initials of a person, colored deterministically by name.
class AvatarInitials extends StatelessWidget {
  final String name;
  final double size;

  const AvatarInitials({super.key, required this.name, this.size = 24});

  static const _palette = [
    Color(0xFF1D7AFC),
    Color(0xFF22A06B),
    Color(0xFF8F7EE7),
    Color(0xFFE56910),
    Color(0xFFE774BB),
    Color(0xFF2898BD),
    Color(0xFFC9372C),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Icon(
        Icons.account_circle_outlined,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first.characters.first}${parts.last.characters.first}'
        : parts.first.characters.take(2).toString();
    final color =
        _palette[trimmed.codeUnits.fold(0, (a, b) => a + b) % _palette.length];
    return Tooltip(
      message: trimmed,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
