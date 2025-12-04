import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat/src/rust/api/rust.dart';
import 'package:groupchat/ui/image_editor.dart';
import 'package:image_picker/image_picker.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.images,
    this.initialIndex,
    this.onReplace,
    this.onEdit,
    this.onTrash,
    this.forceCropAspect,
  });

  final List<Img> images;
  final int? initialIndex;
  final void Function(Img image, int index)? onReplace;
  final void Function(Uint8List bytes, int index)? onEdit;
  final void Function(Img image, int index)? onTrash;
  final double? forceCropAspect;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController transformationController =
      TransformationController();
  ScrollPhysics physics = AlwaysScrollableScrollPhysics();
  Brightness statusBarBrightness = Brightness.dark;
  double opacity = 1.0;
  double blur = 8;
  double iconButtonSize = 55;

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
      child: PageView.builder(
        physics: physics,
        controller: PageController(initialPage: widget.initialIndex ?? 0),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return ColoredBox(
            color: Colors.black,
            child: GestureDetector(
              onTap: () => setState(
                () => opacity == 1.0 ? opacity = 0.0 : opacity = 1.0,
              ),
              child: Stack(
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      transformationController: transformationController,
                      child: Center(
                        child: AnyImage(
                          bytes: image.bytes,
                          file: image.file,
                          url: image.url,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: opacity,
                    duration: Duration(milliseconds: 250),
                    child: Column(
                      children: [
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: blur,
                              sigmaY: blur,
                            ),
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
                                    if (image.user != null) ...[
                                      AnyImage(
                                        circle: true,
                                        circleRadius: 25,
                                        bytes: image.bytes,
                                        file: image.file,
                                        url: image.url,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              image.user!.name,
                                              style: TextTheme.of(context)
                                                  .titleMedium
                                                  ?.copyWith(height: 1),
                                            ),
                                            if (image.message?.text !=
                                                null) ...[
                                              SizedBox(height: 2),
                                              Text(
                                                image.message!.text!,
                                                style: TextTheme.of(context)
                                                    .bodyLarge
                                                    ?.copyWith(height: 1),
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
                        if (widget.onReplace != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: 200,
                              height: 40,
                              child: FilledButton(
                                onPressed: () async {
                                  ImagePicker picker = ImagePicker();
                                  var file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (file != null) {
                                    if (widget.forceCropAspect != null) {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageEditor(
                                              image: Img(file: file.path),
                                              cropOnly: true,
                                              forceCropAspect:
                                                  widget.forceCropAspect,
                                              onDone: (bytes) {
                                                widget.onReplace?.call(
                                                  Img(
                                                    bytes: bytes,
                                                    file: file.path,
                                                  ),
                                                  index,
                                                );
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      widget.onReplace?.call(
                                        Img(
                                          bytes: await file.readAsBytes(),
                                          file: file.path,
                                        ),
                                        index,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                                child: Text("New Photo"),
                              ),
                            ),
                          ),
                        ],
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: blur,
                              sigmaY: blur,
                            ),
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
                                  if (widget.onEdit != null) ...[
                                    SizedBox(
                                      height: iconButtonSize,
                                      width: iconButtonSize,
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ImageEditor(
                                                image: image,
                                                forceCropAspect:
                                                    widget.forceCropAspect,
                                                onDone: (bytes) {
                                                  setState(
                                                    () =>
                                                        widget
                                                                .images[index]
                                                                .bytes =
                                                            bytes,
                                                  );
                                                  widget.onEdit?.call(
                                                    bytes,
                                                    index,
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (widget.onTrash != null) ...[
                                    SizedBox(
                                      height: iconButtonSize,
                                      width: iconButtonSize,
                                      child: IconButton(
                                        onPressed: () {
                                          widget.onTrash?.call(image, index);
                                          if (widget.images.length > 1) {
                                            setState(
                                              () =>
                                                  widget.images.removeAt(index),
                                            );
                                          } else {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                  SizedBox(
                                    height: iconButtonSize,
                                    width: iconButtonSize,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.download_outlined,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: iconButtonSize,
                                    width: iconButtonSize,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.share_outlined,
                                        size: 32,
                                      ),
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
        },
      ),
    );
  }
}

class Img {
  Img({this.bytes, this.file, this.url, this.message, this.user});
  Uint8List? bytes;
  String? file;
  String? url;
  final User? user;
  final Message? message;
}

class AnyImage extends StatelessWidget {
  const AnyImage({
    super.key,
    this.bytes,
    this.file,
    this.url,
    this.fit,
    this.width,
    this.height,
    this.circle = false,
    this.circleRadius,
    this.child,
  });

  final Uint8List? bytes;
  final String? file;
  final String? url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final bool circle;
  final double? circleRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: MemoryImage(bytes!),
              radius: circleRadius,
              child: child,
            )
          : Image.memory(bytes!, fit: fit, width: width, height: height);
    } else if (file != null) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: FileImage(File(file!)),
              radius: circleRadius,
              child: child,
            )
          : Image.file(File(file!), fit: fit, width: width, height: height);
    } else if (url != null && url!.startsWith("https://")) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: CachedNetworkImageProvider(url!),
              radius: circleRadius,
              child: child,
            )
          : CachedNetworkImage(
              placeholder: child != null ? (context, url) => child! : null,
              fadeInDuration: Duration(milliseconds: 200),
              imageUrl: url!,
              fit: fit,
              width: width,
              height: height,
            );
    } else {
      return Expanded(child: Center(child: child ?? Text("No Image")));
    }
  }
}
