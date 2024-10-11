import 'package:flutter/material.dart';

abstract class ThemeStyle {
  static late Color primaryColor;
  static late Color backgroundColor;
  static late Color appbarColor;
  static late Color textColor;
  static late Color textMinorColor;
  static ThemeData getThemeData(
      {Color? primaryColor,
      Color? backgroundColor,
      Color? appbarColor,
      Color? textColor,
      Color? textMinorColor,
      bool backButtonColorBlack = false}) {
    return ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android:
                CupertinoPageTransitionsBuilder() //MyRouteTransitionBuilder()
          },
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor ?? Colors.black, primary: primaryColor),
        useMaterial3: true,
        brightness: Brightness.light,
        // 字体
        fontFamily: null,
        // 文字
        textTheme: TextTheme(
          displayLarge: TextStyle(color: textColor),
          displayMedium: TextStyle(color: textColor),
          displaySmall: TextStyle(color: textColor),
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textMinorColor),
          bodySmall: TextStyle(color: textColor),
        ),
        // 主颜色
        primaryColor: primaryColor,

        // scaffold背景颜色
        scaffoldBackgroundColor:
            backgroundColor, // 0xFFF7F7F7 0xFFF9F9F9 0xFFF6F8FA 0xFFFCFBFC
        // bottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        // 点击时水波颜色
        splashColor: Colors.transparent,
        // 点击时背景高亮颜色
        highlightColor: Colors.transparent,
        // Card
        cardColor: Colors.white,
        // bottomSheet
        bottomSheetTheme:
            const BottomSheetThemeData(modalBackgroundColor: Color(0xFFF6F8FA)),
        // Radio
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
        appBarTheme: AppBarTheme(
            color: appbarColor,
            titleTextStyle: TextStyle(
                color: backButtonColorBlack ? Colors.black : Colors.white,
                fontSize: 20),
            surfaceTintColor: Colors.transparent,
            iconTheme: IconThemeData(
                color: backButtonColorBlack ? Colors.black : Colors.white)),
        iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent))));
  }
}
