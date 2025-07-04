import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;
  final bool fullWidth;

  const NavButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: color ?? Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: buttonStyle,
          )
        : ElevatedButton(
            onPressed: onPressed,
            child: Text(text),
            style: buttonStyle,
          );
  }
}
