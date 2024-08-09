import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
InputDecoration coInputDecoration(
    {IconData? prefixIcon,
      required BuildContext context,
      String? hint,
      Color? bgColor,
      Color? borderColor,
      EdgeInsets? padding}) {
  return InputDecoration(
    contentPadding:
    padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    counter: Offstage(),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
        BorderSide(color: borderColor ?? Theme.of(context).primaryColor)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
    ),
    fillColor: bgColor ?? Theme.of(context).primaryColor.withOpacity(0.04),
    hintText: hint,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: Colors.blue)
        : null,
    hintStyle: secondaryTextStyle(),
    filled: true,
  );
}

/*Widget commonCacheImageWidget(String? url, double height,
    {double? width, BoxFit? fit}) {
  if (url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder:
        placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorWidget: (_, __, ___) {
          return SizedBox(height: height, width: width);
        },
      );
    } else {
      return Image.network(url!,
          height: height, width: width, fit: fit ?? BoxFit.cover);
    }
  } else {
    return Image.asset(url!,
        height: height, width: width, fit: fit ?? BoxFit.cover);
  }
}
*/
/*Widget? Function(BuildContext, String) placeholderWidgetFn() =>
        (_, s) => placeholderWidget();

Widget placeholderWidget() =>
    Image.asset(Images.placeholder, fit: BoxFit.cover);
*/
/*Widget commonCachedNetworkImage(
    String? url, {
      double? height,
      double? width,
      BoxFit? fit,
      AlignmentGeometry? alignment,
      bool usePlaceholderIfUrlEmpty = true,
      double? radius,
      Color? color,
    }) {
  if (url!.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(url,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}
*/
/*Widget placeHolderWidget(
    {double? height,
      double? width,
      BoxFit? fit,
      AlignmentGeometry? alignment,
      double? radius}) {
  return Image.asset(Images.placeholder,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}
*/
void changeStatusBarColor(Color color) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: color,
  ));
}

Widget BackToPreviousIcon(BuildContext context, Color color) {
  return Align(
    alignment: Alignment.topLeft,
    child: Icon(Icons.arrow_back, color: color, size: 18),
  ).onTap(() {
    finish(context);
  });
}
