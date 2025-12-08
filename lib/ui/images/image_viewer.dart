import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'any_image.dart';
import 'image_utils.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer(
    this.images, {
    super.key,
    this.initialIndex,
    this.forceCropAspect,
    this.canReplace = false,
    this.canEdit = false,
    this.canTrash = false,
    this.leaveOnChange = false,
    this.onChange,
  });

  final List<Img> images;
  final int? initialIndex;
  final double? forceCropAspect;
  final bool canReplace;
  final bool canEdit;
  final bool canTrash;
  final bool leaveOnChange;
  final void Function(int index, Img img)? onChange;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController transformationController =
      TransformationController();
  late final PageController pageController;
  ScrollPhysics physics = AlwaysScrollableScrollPhysics();
  Brightness statusBarBrightness = Brightness.dark;
  double opacity = 1.0;
  double blur = 8;
  double iconButtonSize = 55;
  late int currentIndex;

  @override
  void initState() {
    transformationController.addListener(() {
      if (transformationController.value.storage[0] > 1.0 ||
          transformationController.value.storage[5] > 1.0) {
        if (physics is AlwaysScrollableScrollPhysics) {
          setState(() => physics = NeverScrollableScrollPhysics());
        }
      } else {
        if (physics is NeverScrollableScrollPhysics) {
          setState(() => physics = AlwaysScrollableScrollPhysics());
        }
      }
    });
    currentIndex = widget.initialIndex ?? 0;
    pageController = PageController(initialPage: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var systemPadding = MediaQuery.of(context).padding;
    var isLight = Theme.brightnessOf(context) == Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
      child: GestureDetector(
        onTap: () =>
            setState(() => opacity == 1.0 ? opacity = 0.0 : opacity = 1.0),
        child: Stack(
          children: [
            /// =============================
            /// Picture Carousel
            /// =============================
            PageView.builder(
              physics: physics,
              controller: pageController,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => currentIndex = value),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: transformationController,
                  child: Center(
                    child: AnyImage(widget.images[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),

            /// =============================
            /// Options Overlay
            /// =============================
            AnimatedOpacity(
              opacity: opacity,
              duration: Duration(milliseconds: 250),
              child: Column(
                children: [
                  /// =============================
                  /// Top Options Bar
                  /// =============================
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.only(
                          top: 8 + systemPadding.top,
                          bottom: 8,
                        ),
                        color: isLight ? Colors.white60 : Colors.black54,
                        child: Center(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close, size: 30),
                                ),
                              ),

                              /// =============================
                              /// User and Message Display
                              /// =============================
                              if (widget.images[currentIndex].user != null) ...[
                                AnyImage(
                                  circle: true,
                                  circleRadius: 25,
                                  widget.images[currentIndex],
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.images[currentIndex].user!.name,
                                        style: TextTheme.of(
                                          context,
                                        ).titleMedium?.copyWith(height: 1),
                                      ),
                                      if (widget
                                              .images[currentIndex]
                                              .message
                                              ?.text !=
                                          null) ...[
                                        SizedBox(height: 2),
                                        Text(
                                          widget
                                              .images[currentIndex]
                                              .message!
                                              .text!,
                                          style: TextTheme.of(
                                            context,
                                          ).bodyLarge?.copyWith(height: 1),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),

                  /// =============================
                  /// Bottom Options Bar
                  /// =============================
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.only(
                          bottom: 5 + systemPadding.bottom,
                          left: 5,
                          right: 5,
                          top: 5,
                        ),
                        width: double.infinity,
                        color: isLight ? Colors.white60 : Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 5,
                          children: [
                            /// =============================
                            /// Replace Button
                            /// =============================
                            if (widget.canReplace) ...[
                              SizedBox(
                                height: iconButtonSize,
                                width: iconButtonSize,
                                child: IconButton.filled(
                                  onPressed: () {
                                    ImageUtils.pickImage(
                                      context,
                                      crop: widget.forceCropAspect,
                                      onChosen: (newImage) {
                                        widget.images[currentIndex] = newImage;
                                        widget.onChange?.call(
                                          currentIndex,
                                          newImage,
                                        );
                                        if (widget.leaveOnChange) {
                                          Navigator.pop(context);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],

                            /// =============================
                            /// Edit Button
                            /// =============================
                            if (widget.canEdit) ...[
                              SizedBox(
                                height: iconButtonSize,
                                width: iconButtonSize,
                                child: IconButton(
                                  onPressed: () {
                                    ImageUtils.editImage(
                                      context,
                                      widget.images[currentIndex],
                                      forceCropAspect: widget.forceCropAspect,
                                      onDone: (newImage) {
                                        widget.images[currentIndex] = newImage;
                                        widget.onChange?.call(
                                          currentIndex,
                                          newImage,
                                        );
                                        if (widget.leaveOnChange) {
                                          Navigator.pop(context);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.edit_outlined, size: 32),
                                ),
                              ),
                            ],

                            /// =============================
                            /// Trash Button
                            /// =============================
                            if (widget.canTrash) ...[
                              SizedBox(
                                height: iconButtonSize,
                                width: iconButtonSize,
                                child: IconButton(
                                  onPressed: () {
                                    widget.images.removeAt(currentIndex);
                                    widget.onChange?.call(currentIndex, Img());
                                    if (widget.images.isEmpty ||
                                        widget.leaveOnChange) {
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(Icons.delete_outline, size: 32),
                                ),
                              ),
                            ],

                            /// =============================
                            /// Download Button
                            /// =============================
                            SizedBox(
                              height: iconButtonSize,
                              width: iconButtonSize,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.download_outlined, size: 32),
                              ),
                            ),

                            /// =============================
                            /// Share Button
                            /// =============================
                            SizedBox(
                              height: iconButtonSize,
                              width: iconButtonSize,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.share_outlined, size: 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
