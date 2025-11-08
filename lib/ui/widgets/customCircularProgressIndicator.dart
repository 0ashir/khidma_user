import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    final Key? key,
    this.color,
    this.strokeWidth,
    this.widthAndHeight,
  }) : super(key: key);
  final Color? color;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  Widget build(final BuildContext context) => Center(
        child: SizedBox(
          height: widthAndHeight?.rf(context) ?? 30.rf(context),
          width: widthAndHeight?.rw(context) ?? 30.rw(context),
          child: Platform.isAndroid
              ? CircularProgressIndicator(
                  color: color ?? context.colorScheme.accentColor,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 1.5,
                )
              : CupertinoActivityIndicator(
                  color: color ?? Colors.transparent,
                ),
        ),
      );
}
