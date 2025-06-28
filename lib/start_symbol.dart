import 'package:flutter/material.dart';

class StartSymbol extends StatelessWidget {
  final String symbol;
  final bool selected;
  final String text;

  const StartSymbol({this.text = '', this.symbol = '', this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: selected ? Colors.blue[200] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 3,
        ),
      ),
      child:
          text.isEmpty
              ? Image.asset(
                'assets/images/$symbol.png',
                scale: 1.7,
                fit: BoxFit.fill,
              )
              : Center(
                heightFactor: 1,
                child: Text(
                  text,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
    );
  }
}
