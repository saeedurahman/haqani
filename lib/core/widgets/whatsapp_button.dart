import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

const whatsAppGreen = Color(0xFF25D366);
const _whatsAppDark = Color(0xFF128C7E);

/// "Send to Parent on WhatsApp". Opens WhatsApp with a ready message.
class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({super.key, required this.onPressed, this.label = 'Send to Parent on WhatsApp'});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [whatsAppGreen, _whatsAppDark]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: whatsAppGreen.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
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

/// Small round WhatsApp button for lists.
class WhatsAppIconButton extends StatelessWidget {
  const WhatsAppIconButton({super.key, required this.onPressed, this.tooltip = 'Send to Parent on WhatsApp'});

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: whatsAppGreen.withValues(alpha: 0.14),
        foregroundColor: _whatsAppDark,
      ),
      icon: const Icon(Icons.chat_rounded, size: 20, color: AppColors.success),
    );
  }
}
