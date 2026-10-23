import 'package:flutter/material.dart';

import '../../domain/attendance_models.dart';
import 'status_colors.dart';

/// Three big buttons. Tap one to choose it.
class StatusToggle extends StatelessWidget {
  const StatusToggle({super.key, required this.status, required this.onChanged});

  final String? status;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in AttendanceStatus.all) ...[
          _Choice(
            status: s,
            selected: s == status,
            onTap: () => onChanged(s),
          ),
          if (s != AttendanceStatus.all.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.status, required this.selected, required this.onTap});

  final String status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = attendanceColor(status);
    return Semantics(
      button: true,
      selected: selected,
      label: AttendanceStatus.label(status),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          constraints: const BoxConstraints(minWidth: 104),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : color.withValues(alpha: 0.25)),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(attendanceIcon(status), size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                AttendanceStatus.label(status),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
