import 'package:flutter/material.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PolicyPageState();
  }
}

class _PolicyPageState extends State<PolicyPage> {

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).colorScheme.secondary);
  }
}
