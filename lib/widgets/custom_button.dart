import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String tag;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    this.height,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final Color finalBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.secondary;
    final Color finalTextColor = textColor ?? Theme.of(context).colorScheme.onSecondary;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Hero(
        tag: tag,
        child: Container(
          decoration: BoxDecoration(
            color: finalBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          height: height ?? 59,
          child: isLoading
              ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSecondary,
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Text(
                  text,
                  style: TextStyle(
                    color: finalTextColor,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8.0),
                Icon(
                  icon,
                  size: 25,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
