import 'package:flutter/material.dart';

class OAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const OAuthButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.6)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
