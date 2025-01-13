import 'package:flutter/material.dart';

class CreateNewStudioComponent extends StatefulWidget {

  const CreateNewStudioComponent({super.key});

  @override
  State<CreateNewStudioComponent> createState() => _CreateNewStudioComponentState();
}

class _CreateNewStudioComponentState extends State<CreateNewStudioComponent> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}