import "package:material_ui/material_ui.dart";

Widget addVerticalGap(double height) => SizedBox(height: height);
Widget addHorizontalGap(double width) => SizedBox(width: width);

Widget drawerDivider() =>
    const Divider(indent: 20, endIndent: 20, radius: .all(.circular(10)));
