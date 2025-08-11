import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(25),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        onHighlightChanged: (value) {
          setState(() {
            isPressed = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          width: isPressed ? 160 : 180,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
