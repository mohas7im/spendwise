import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final String saveText;
  final String cancelText;
  final bool isScrollable;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final List<Widget>? headerActions;
  final Color? headerTextColor;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.saveText = 'Save',
    this.cancelText = 'Cancel',
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.backgroundColor,
    this.headerActions,
    this.headerTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        height: (MediaQuery.of(context).size.height * 0.92 - bottomInset).clamp(300.0, double.infinity),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(cancelText, style: TextStyle(color: headerTextColor?.withValues(alpha: 0.6) ?? Colors.grey)),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: headerTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (headerActions != null)
                    ...headerActions!
                  else if (onSave != null)
                    TextButton(
                      onPressed: onSave,
                      child: Text(saveText, style: TextStyle(color: headerTextColor ?? const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    )
                  else
                    const SizedBox(width: 64), // Balance the title centering
                ],
              ),
            ),
            Expanded(
              child: isScrollable
                  ? SingleChildScrollView(
                      padding: padding,
                      child: child,
                    )
                  : Padding(
                      padding: padding,
                      child: child,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
