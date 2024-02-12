import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../models/user.dart';
import '../../singletons/shared_local_storage.dart';

class Login extends StatefulWidget {


  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {

  bool loading = false;
  User existingUser = User();
  double? secondStepCurveHeight;

  String errorMsg = "Network Issues!";

  void _signIn() async{

  }

  @override
  void initState() {
    super.initState();
    try{
      User? user;
      Future.delayed(Duration.zero, () async{
        user = await myStorage.getFromStore(key: 'user');
        if(mounted) {
          setState(() {
            existingUser.pin = user?.pin;
          });
        }
      });
    }catch(ex){
      debugPrint("SetState Issues $ex");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double width = screen.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool poped) async => poped,
      child: const Scaffold(
          resizeToAvoidBottomInset: false,
      ),
    );
  }
}
