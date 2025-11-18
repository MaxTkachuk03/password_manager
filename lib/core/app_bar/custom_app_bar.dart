import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/core/theme/app_colors.dart';

enum CustomAppBarTextTheme { light, dark }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final CustomAppBarTextTheme? textTheme;
  final String? subtitle;
  final Widget? leading;
  final bool isNeedLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final GestureTapCallback? onTap;
  final Color? customColor;
  final bool? isLightTextTheme;

  const CustomAppBar({
    super.key,
    required this.title,
    this.systemOverlayStyle = SystemUiOverlayStyle.dark,
    this.textTheme = CustomAppBarTextTheme.dark,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.bottom,
    this.onTap,
    this.customColor,
    this.isLightTextTheme,
    this.isNeedLeading = false,
  });

  factory CustomAppBar.customColor({
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool isPsychology = false,
    Color? customColor,
    bool isNeedLeading = false,
  }) => CustomAppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    textTheme: isPsychology
        ? CustomAppBarTextTheme.light
        : CustomAppBarTextTheme.dark,
    backgroundColor: customColor,
    title: title,
    subtitle: subtitle,
    leading: leading,
    isNeedLeading: isNeedLeading,
    actions: actions,
    bottom: bottom,
    isLightTextTheme: isPsychology,
  );

  factory CustomAppBar.transparent({
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
  }) => CustomAppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    textTheme: CustomAppBarTextTheme.dark,
    backgroundColor: AppColors.transparent,
    title: title,
    subtitle: subtitle,
    leading: leading,
    actions: actions,
  );

  factory CustomAppBar.green({
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool isNeedLeading = false,
  }) => CustomAppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    textTheme: CustomAppBarTextTheme.dark,
    backgroundColor: AppColors.greenRegular,
    title: title,
    subtitle: subtitle,
    leading: leading,
    isNeedLeading: isNeedLeading,
    actions: actions,
    bottom: bottom,
  );

  factory CustomAppBar.blue({
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool isNeedLeading = false,
  }) => CustomAppBar(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    textTheme: CustomAppBarTextTheme.light,
    backgroundColor: AppColors.blueRegular,
    title: title,
    subtitle: subtitle,
    leading: leading,
    isNeedLeading: isNeedLeading,
    actions: actions,
    bottom: bottom,
  );

  factory CustomAppBar.dark({
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    bool isNeedLeading = false,
  }) => CustomAppBar(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    textTheme: CustomAppBarTextTheme.light,
    backgroundColor: AppColors.blueDarkest,
    title: title,
    subtitle: subtitle,
    leading: leading,
    actions: actions,
    isNeedLeading: isNeedLeading,
  );

  Color get _titleColor => textTheme == CustomAppBarTextTheme.dark
      ? AppColors.blueDarker
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _Title(title: title, subtitle: subtitle, onTap: onTap),
      titleTextStyle: AppBarTheme.of(
        context,
      ).titleTextStyle?.copyWith(color: _titleColor),
      backgroundColor: backgroundColor,
      forceMaterialTransparency: backgroundColor == AppColors.transparent,
      automaticallyImplyLeading: false,
      leading: isNeedLeading
          ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: leading ?? const BackButton(),
            )
          : null,
      actions: actions,
      bottom: bottom,
      scrolledUnderElevation: 0,
    );
  }

  double get getBottomPreferredSize => bottom?.preferredSize.height ?? 0;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + getBottomPreferredSize);
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final GestureTapCallback? onTap;

  const _Title({required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title ?? '',
          maxLines: subtitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          InkWell(
            onTap: onTap,
            highlightColor: AppColors.transparent,
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
