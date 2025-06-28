import 'package:flutter/material.dart';

class BoardItem extends StatelessWidget {
  final String text;
  final int index;
  final void Function(int) onPressed;
  final bool highlighted;

  const BoardItem({super.key, 
    required this.onPressed,
    required this.text,
    required this.index,
    this.highlighted = false,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: highlighted ? Colors.lightGreen : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: text.isEmpty ? null : Image.asset('assets/images/$text.png'),
        ),
      ),
    );
  }
}
