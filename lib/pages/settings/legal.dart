import 'package:flutter/material.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LegalPageState();
  }
}

class LegalPageState extends State<LegalPage> {

  @override
  void initState(){
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).colorScheme.secondary);
  }
}
