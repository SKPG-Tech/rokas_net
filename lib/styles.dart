import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

const _kNoto = GoogleFonts.notoSans;
const _kMontserrat = GoogleFonts.montserrat;
final _textStyle = ThemeData.dark().textTheme;

abstract final class Styles {
  static final text = TextTheme(
    displayLarge: _kMontserrat(textStyle: _textStyle.displayLarge),
    displayMedium: _kMontserrat(textStyle: _textStyle.displayMedium),
    displaySmall: _kMontserrat(textStyle: _textStyle.displaySmall),
    headlineLarge: _kMontserrat(textStyle: _textStyle.headlineLarge),
    headlineMedium: _kMontserrat(textStyle: _textStyle.headlineMedium),
    headlineSmall: _kMontserrat(textStyle: _textStyle.headlineSmall),
    titleLarge: _kNoto(textStyle: _textStyle.titleLarge),
    titleMedium: _kNoto(textStyle: _textStyle.titleMedium),
    titleSmall: _kNoto(textStyle: _textStyle.titleSmall),
    bodyLarge: _kNoto(textStyle: _textStyle.bodyLarge),
    bodyMedium: _kNoto(textStyle: _textStyle.bodyMedium),
    bodySmall: _kNoto(textStyle: _textStyle.bodySmall),
    labelLarge: _kNoto(textStyle: _textStyle.labelLarge),
    labelMedium: _kNoto(textStyle: _textStyle.labelMedium),
    labelSmall: _kNoto(textStyle: _textStyle.labelSmall),
  );

  static const colors = ColorScheme.dark(
    primary: Color(0xff007bA7),
    onPrimary: Color(0xffffffff),
    secondary: Color(0xff175a73),
    onSecondary: Color(0xffbababa),
    tertiary: Color(0xff1a3640),
    surface: Color(0xff1a1a1a),
    surfaceBright: Color(0xff323232),
  );
}
