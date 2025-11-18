import 'package:flutter/material.dart';
import 'package:password_manager/core/app_bar/custom_app_bar.dart';
import 'package:password_manager/core/scaffold/custom_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold.blue(
      appBar: CustomAppBar.green(
        title: 'Login',
        bottom: PreferredSize(preferredSize: Size(100, 10), child: Text("lohhhh"))
      ),
      body: Column(

        
      ),
    );
  }
}
