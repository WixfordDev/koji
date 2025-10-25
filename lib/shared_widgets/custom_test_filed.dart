// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../constants/app_font_manager.dart';
//
// class TextFieldCustom extends StatelessWidget {
//   final String? labelText;
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onFieldSubmit;
//   final ValueChanged<String>? onChanged;
//   final VoidCallback? onTap;
//   final String? hintText;
//
//   final VoidCallback? onTapSuffixIcon;
//   final VoidCallback? onTapPrefixIcon;
//   final IconData? suffixIconData;
//   final IconData? prefixIconData;
//
//   final FocusNode? focusNode;
//
//   final Color? backgroundColor;
//   final Color? hintTextColor;
//   final Color? cursorColor;
//   final Color? textColor;
//   final Color? prefixIconColor;
//   final Color? suffixIconColor;
//
//   final Widget? prefixWidget;
//
//   final TextInputType? inputType;
//   final TextInputAction? textInputAction;
//
//   final bool? obscureText;
//   final String obscuringCharacter;
//
//   final double? borderRadius;
//   final double? borderWidth;
//   final Color? borderColor;
//   final bool? borderSide;
//
//   final String? errorText;
//   final bool? readOnly;
//
//   final List<TextInputFormatter>? inputFormatters;
//   final int? maxLines;
//   final int? maxLength;
//   final bool hideCounter;
//
//   final TextAlign? textAlign;
//
//   final List<String>? autofillHints;
//   final bool enableSuggestions;
//   final bool autocorrect;
//
//   static const Color _textFieldThemeColor = Color(0xff3d475a);
//
//   const TextFieldCustom({
//     super.key,
//     this.textAlign,
//     this.readOnly = false,
//     this.inputFormatters,
//     this.labelText,
//     required this.controller,
//     this.validator,
//     this.onFieldSubmit,
//     this.hintText,
//     this.onTapSuffixIcon,
//     this.suffixIconData,
//     this.prefixIconData,
//     this.onTapPrefixIcon,
//     this.focusNode,
//     this.backgroundColor = Colors.white,
//     this.hintTextColor = _textFieldThemeColor,
//     this.cursorColor = _textFieldThemeColor,
//     this.textColor = _textFieldThemeColor,
//     this.prefixIconColor = const Color(0xff3d475a),
//     this.suffixIconColor = const Color(0xff3d475a),
//     this.borderColor = const Color(0x332575FC),
//     this.prefixWidget,
//     this.inputType = TextInputType.text,
//     this.textInputAction,
//     this.obscureText = false,
//     this.obscuringCharacter = '•',
//     this.borderRadius = 15,
//     this.borderSide = false,
//     this.onTap,
//     this.onChanged,
//     this.errorText,
//     this.borderWidth = 1.2,
//     this.maxLines = 1,
//     this.maxLength,
//     this.hideCounter = true,
//     this.autofillHints,
//     this.enableSuggestions = true,
//     this.autocorrect = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final baseText = theme.textTheme.bodyMedium;
//
//     return TextFormField(
//       textAlign: textAlign ?? TextAlign.start,
//       maxLines: maxLines,
//       maxLength: maxLength,
//       inputFormatters: inputFormatters,
//       readOnly: readOnly ?? false,
//       onChanged: onChanged,
//       onTap: onTap,
//       obscureText: obscureText ?? false,
//       obscuringCharacter: obscuringCharacter,
//       keyboardType: inputType,
//       textInputAction: textInputAction,
//       focusNode: focusNode,
//       validator: validator,
//       cursorWidth: 1,
//       cursorColor: cursorColor,
//       autofocus: false,
//       controller: controller,
//       autofillHints: autofillHints, // 👈 enables email/password autofill
//       enableSuggestions: enableSuggestions,
//       autocorrect: autocorrect,
//       onFieldSubmitted: onFieldSubmit,
//       style: baseText?.copyWith(
//         decoration: TextDecoration.none,
//         // If you use FontSize.f16 from your font manager, swap this next line:
//         // fontSize: FontSize.f16,
//         fontSize: 16.sp,
//         color: textColor,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: backgroundColor,
//         errorMaxLines: 3,
//         hoverColor: Colors.white,
//         errorText: errorText,
//
//         // Label & hint
//         labelText: labelText,
//         labelStyle: baseText?.copyWith(
//           color: Colors.black45,
//           // fontSize: FontSize.f16,
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//         ),
//         hintText: hintText,
//         hintStyle: baseText?.copyWith(
//           fontWeight: FontWeight.w500,
//           fontSize: 16.sp,
//           color: hintTextColor,
//           fontFamily: FontConstants.poppinsRegular,
//         ),
//
//         // Padding
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 20.w,
//           vertical: (maxLines ?? 1) > 1 ? 12.h : 12.h,
//         ),
//
//         // Icons (taps are optional; no forced null-assertion)
//         suffixIcon: suffixIconData == null
//             ? null
//             : InkWell(
//                 onTap: onTapSuffixIcon,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12.w),
//                   child: Icon(
//                     suffixIconData,
//                     size: 20.sp,
//                     color: suffixIconColor,
//                   ),
//                 ),
//               ),
//         prefixIconConstraints: BoxConstraints.tight(Size(40.w, 40.w)),
//         suffixIconConstraints: BoxConstraints.tight(Size(40.w, 40.w)),
//         prefixIcon:
//             prefixWidget ??
//             (prefixIconData == null
//                 ? null
//                 : InkWell(
//                     onTap: onTapPrefixIcon,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 12.w),
//                       child: Icon(
//                         prefixIconData,
//                         size: 18.sp,
//                         color: prefixIconColor,
//                       ),
//                     ),
//                   )),
//
//         // Borders
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(borderRadius ?? 15),
//           borderSide: (borderSide ?? false)
//               ? BorderSide(
//                   color: borderColor ?? const Color(0x332575FC),
//                   width: borderWidth ?? 1.2,
//                 )
//               : BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(borderRadius ?? 15),
//           borderSide: (borderSide ?? false)
//               ? BorderSide(
//                   color: (borderColor ?? const Color(0xFF2575FC)),
//                   width: (borderWidth ?? 1.2) + 0.3,
//                 )
//               : BorderSide.none,
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(borderRadius ?? 15),
//           borderSide: BorderSide(
//             color: Colors.red.shade400,
//             width: (borderWidth ?? 1.2) + 0.3,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(borderRadius ?? 15),
//           borderSide: BorderSide(
//             color: Colors.red.shade400,
//             width: (borderWidth ?? 1.2) + 0.3,
//           ),
//         ),
//
//         // Counter
//         counterText: hideCounter ? '' : null,
//
//         // Error text style subtle & readable
//         errorStyle: baseText?.copyWith(
//           color: Colors.red.shade600,
//           fontSize: 12.sp,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldCustom extends StatelessWidget {
  final String? labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmit;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? hintText;

  final VoidCallback? onTapSuffixIcon;
  final VoidCallback? onTapPrefixIcon;
  final IconData? suffixIconData;
  final IconData? prefixIconData;

  final FocusNode? focusNode;

  final Color? backgroundColor;
  final Color? hintTextColor;
  final Color? cursorColor;
  final Color? textColor;
  final Color? prefixIconColor;
  final Color? suffixIconColor;

  final Widget? prefixWidget;

  final TextInputType? inputType;
  final TextInputAction? textInputAction;

  final bool? obscureText;
  final String obscuringCharacter;

  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final bool? borderSide;

  final String? errorText;
  final bool? readOnly;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool hideCounter;

  final TextAlign? textAlign;

  final List<String>? autofillHints;
  final bool enableSuggestions;
  final bool autocorrect;

  static const Color _textFieldThemeColor = Color(0xff3d475a);

  const TextFieldCustom({
    super.key,
    this.textAlign,
    this.readOnly = false,
    this.inputFormatters,
    this.labelText,
    required this.controller,
    this.validator,
    this.onFieldSubmit,
    this.hintText,
    this.onTapSuffixIcon,
    this.suffixIconData,
    this.prefixIconData,
    this.onTapPrefixIcon,
    this.focusNode,
    this.backgroundColor = Colors.white,
    this.hintTextColor = _textFieldThemeColor,
    this.cursorColor = _textFieldThemeColor,
    this.textColor = _textFieldThemeColor,
    this.prefixIconColor = const Color(0xff3d475a),
    this.suffixIconColor = const Color(0xff3d475a),
    this.borderColor = const Color(0x332575FC),
    this.prefixWidget,
    this.inputType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.borderRadius = 15,
    this.borderSide = false,
    this.onTap,
    this.onChanged,
    this.errorText,
    this.borderWidth = 1.2,
    this.maxLines = 1,
    this.maxLength,
    this.hideCounter = true,
    this.autofillHints,
    this.enableSuggestions = true,
    this.autocorrect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseText = theme.textTheme.bodyMedium;

    return TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      readOnly: readOnly ?? false,
      onChanged: onChanged,
      onTap: onTap,
      obscureText: obscureText ?? false,
      obscuringCharacter: obscuringCharacter,
      keyboardType: inputType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      validator: validator,
      cursorWidth: 1,
      cursorColor: cursorColor,
      autofocus: false,
      controller: controller,
      autofillHints: autofillHints, // 👈 enables email/password autofill
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      onFieldSubmitted: onFieldSubmit,
      style: baseText?.copyWith(
        decoration: TextDecoration.none,
        // If you use FontSize.f16 from your font manager, swap this next line:
        // fontSize: FontSize.f16,
        fontSize: 16.sp,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor,
        errorMaxLines: 3,
        hoverColor: Colors.white,
        errorText: errorText,

        // Label & hint
        labelText: labelText,
        labelStyle: baseText?.copyWith(
          color: Colors.black45,
          // fontSize: FontSize.f16,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        hintText: hintText,
        hintStyle: baseText?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: hintTextColor,

          // fontFamily: FontConstants.poppinsRegular,
        ),

        // Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: (maxLines ?? 1) > 1 ? 12.h : 12.h,
        ),

        // Icons (taps are optional; no forced null-assertion)
        suffixIcon: suffixIconData == null
            ? null
            : InkWell(
                onTap: onTapSuffixIcon,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    suffixIconData,
                    size: 20.sp,
                    color: suffixIconColor,
                  ),
                ),
              ),
        prefixIconConstraints: BoxConstraints.tight(Size(40.w, 40.w)),
        suffixIconConstraints: BoxConstraints.tight(Size(40.w, 40.w)),
        prefixIcon:
            prefixWidget ??
            (prefixIconData == null
                ? null
                : InkWell(
                    onTap: onTapPrefixIcon,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        prefixIconData,
                        size: 18.sp,
                        color: prefixIconColor,
                      ),
                    ),
                  )),

        // Borders
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 15),
          borderSide: (borderSide ?? false)
              ? BorderSide(
                  color: borderColor ?? const Color(0x332575FC),
                  width: borderWidth ?? 1.2,
                )
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 15),
          borderSide: (borderSide ?? false)
              ? BorderSide(
                  color: (borderColor ?? const Color(0xFF2575FC)),
                  width: (borderWidth ?? 1.2) + 0.3,
                )
              : BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 15),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: (borderWidth ?? 1.2) + 0.3,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 15),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: (borderWidth ?? 1.2) + 0.3,
          ),
        ),

        // Counter
        counterText: hideCounter ? '' : null,

        // Error text style subtle & readable
        errorStyle: baseText?.copyWith(
          color: Colors.red.shade600,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
