// import 'package:flutter_html/flutter_html.dart';
// import '../../../../config.dart';

// class ReadMoreLayout extends StatefulWidget {
//   final String? text;
//   final bool isHtml;
//   final Color? color;
//   final int trimLines;

//   const ReadMoreLayout({
//     super.key,
//     this.text,
//     this.color,
//     this.isHtml = false,
//     this.trimLines = 4,
//   });

//   @override
//   State<ReadMoreLayout> createState() => _ReadMoreLayoutState();
// }

// class _ReadMoreLayoutState extends State<ReadMoreLayout> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final textColor = widget.color ?? appColor(context).darkText;

//     final lineHeight = 24.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AnimatedSize(
//           duration: const Duration(milliseconds: 200),
//           child: ConstrainedBox(
//             constraints: isExpanded
//                 ? const BoxConstraints()
//                 : BoxConstraints(
//                     maxHeight: widget.trimLines * lineHeight,
//                   ),
//             child: widget.isHtml
//                 ? Html(
//                     data: widget.text ?? '',
//                     style: {
//                       "*": Style(
//                         color: textColor,
//                         fontFamily: GoogleFonts.dmSans().fontFamily,
//                         fontWeight: FontWeight.w500,
//                         fontSize: FontSize(16),
//                         margin: Margins.zero,
//                         padding: HtmlPaddings.zero,
//                       ),
//                     },
//                   )
//                 : Text(
//                     widget.text ?? '',
//                     style: TextStyle(
//                       color: textColor,
//                       fontFamily: GoogleFonts.dmSans().fontFamily,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                     ),
//                   ),
//           ),
//         ),
//         InkWell(
//           onTap: () => setState(() => isExpanded = !isExpanded),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               isExpanded
//                   ? language(context, translations!.readLess)
//                   : language(context, translations!.readMore),
//               style: TextStyle(
//                 color: textColor,
//                 fontFamily: GoogleFonts.dmSans().fontFamily,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter_html/flutter_html.dart';
import '../../../../config.dart';

class ReadMoreLayout extends StatefulWidget {
  final String? text;
  final bool isHtml;
  final Color? color;
  final int trimLines;

  const ReadMoreLayout({
    super.key,
    this.text,
    this.color,
    this.isHtml = false,
    this.trimLines = 4,
  });

  @override
  State<ReadMoreLayout> createState() => _ReadMoreLayoutState();
}

class _ReadMoreLayoutState extends State<ReadMoreLayout> {
  bool isExpanded = false;
  bool hasOverflow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOverflow();
  }

  void _checkOverflow() {
    if (widget.text == null || widget.text!.isEmpty) {
      hasOverflow = false;
      return;
    }

    if (!widget.isHtml) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.text,
          style: TextStyle(
            fontFamily: GoogleFonts.dmSans().fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        maxLines: widget.trimLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: MediaQuery.of(context).size.width);

      hasOverflow = textPainter.didExceedMaxLines;
    } else {
      /// Approximation for HTML (line-height based)
      final estimatedLines =
          (widget.text!.length / 40).ceil(); // safe heuristic
      hasOverflow = estimatedLines > widget.trimLines;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.color ?? appColor(context).darkText;
    const lineHeight = 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : BoxConstraints(
                    maxHeight: widget.trimLines * lineHeight,
                  ),
            child: widget.isHtml
                ? Html(
                    data: widget.text ?? '',
                    style: {
                      "*": Style(
                        color: textColor,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: FontSize(16),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                    },
                  )
                : Text(
                    widget.text ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontFamily: GoogleFonts.dmSans().fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),

        /// ✅ SHOW ONLY WHEN OVERFLOW EXISTS
        if (hasOverflow)
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded
                    ? language(context, translations!.readLess)
                    : language(context, translations!.readMore),
                style: TextStyle(
                  color: textColor,
                  fontFamily: GoogleFonts.dmSans().fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
