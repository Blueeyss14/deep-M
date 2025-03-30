import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';

class BlurBackground extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final BorderRadiusGeometry? borderRadius;
  const BlurBackground({
    super.key,
    this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.alignment,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: margin,
      padding: padding,
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        border: Border.all(
          width: 0.5,
          color: CustomColor.white2.withAlpha(100),
        ),
        gradient: LinearGradient(
          colors: [
            CustomColor.musicBar1.withAlpha(50),
            CustomColor.musicBar2.withAlpha(70),
            CustomColor.musicBar3.withAlpha(80),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: child,
    );
  }
}
