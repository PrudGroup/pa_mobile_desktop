import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

class Translate extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;


  const Translate({super.key, required this.text, this.style = const TextStyle(
      decoration: TextDecoration.none
  ), this.align = TextAlign.start});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: myStorage.translate(text: text),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Text(
          snapshot.data?? text,
          style: style,
          textAlign: align,
        );
      },
    );
  }
}
