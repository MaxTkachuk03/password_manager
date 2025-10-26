import 'package:flutter/material.dart';
import 'package:password_manager/core/app_bar/custom_app_bar.dart';
import 'package:password_manager/core/theme/app_colors.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    this.body,
    required this.color,
    this.resizeToAvoidBottomInset,
    this.bottomSheet,
    this.appBar,
  });

  final CustomAppBar? appBar;
  final Widget? body;
  final Color color;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomSheet;

  factory CustomScaffold.blue({
    Key? key,
    CustomAppBar? appBar,
    Widget? body,
    bool? resizeToAvoidBottomInset,
    Widget? bottomSheet,
  }) => CustomScaffold(
    appBar: appBar,
    color: AppColors.blueRegular,
    body: body,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    key: key,
    bottomSheet: bottomSheet,
  );

  factory CustomScaffold.green({
    Key? key,
    CustomAppBar? appBar,
    Widget? body,
    bool? resizeToAvoidBottomInset,
    Widget? bottomSheet,
  }) => CustomScaffold(
    appBar: appBar,
    color: AppColors.greenRegular,
    body: body,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    key: key,
    bottomSheet: bottomSheet,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: color,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomSheet: bottomSheet,
      body: Stack(children: [if (body != null) body!]),
    );
  }
}
