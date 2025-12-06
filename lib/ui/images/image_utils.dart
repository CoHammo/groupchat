import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../src/rust/api/rust.dart';
import 'image_editor.dart';
import 'image_viewer.dart';

class Img {
  const Img({this.bytes, this.file, this.url, this.user, this.message})
    : editTime = null;

  Img._edited({required this.bytes, this.file, this.url})
    : editTime = DateTime.now().millisecondsSinceEpoch.toString(),
      user = null,
      message = null;

  final Uint8List? bytes;
  final String? file;
  final String? url;
  final User? user;
  final Message? message;
  final String? editTime;

  bool get isBytes => bytes != null;
  bool get isFile => bytes == null && file != null;
  bool get isUrl => bytes == null && file == null && url != null;
  bool get isEmpty => bytes == null && file == null && url == null;
  String get key => "${file ?? url}+$editTime";

  Img edit(Uint8List newBytes) {
    return Img._edited(bytes: newBytes, file: file, url: url);
  }
}

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> viewImages(
    BuildContext context,
    List<Img> images, {
    int? index,
    double? forceCropAspect,
    bool canReplace = false,
    bool canEdit = false,
    bool canTrash = false,
    bool leaveOnChange = false,
    void Function(int index, Img img)? onChange,
    bool transparent = true,
  }) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(Tween(begin: 0, end: 1.0)),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        reverseTransitionDuration: Duration(milliseconds: 200),
        pageBuilder: (context, _, _) {
          var veiwer = ImageViewer(
            images,
            initialIndex: index,
            forceCropAspect: forceCropAspect,
            canEdit: canEdit,
            canReplace: canReplace,
            canTrash: canTrash,
            leaveOnChange: leaveOnChange,
            onChange: onChange,
          );
          if (transparent) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: ColoredBox(
                color: const Color.fromARGB(190, 0, 0, 0),
                child: veiwer,
              ),
            );
          } else {
            return ColoredBox(color: Colors.black, child: veiwer);
          }
        },
      ),
    );
  }

  static Future<void> editImage(
    BuildContext context,
    Img img, {
    bool cropOnly = false,
    double? forceCropAspect,
    required void Function(Img newImage) onDone,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          img,
          cropOnly: cropOnly,
          forceCropAspect: forceCropAspect,
          onDone: onDone,
        ),
      ),
    );
  }

  static Future<void> pickImage(
    BuildContext context, {
    double? crop,
    required void Function(Img image) onChosen,
  }) async {
    var imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (context.mounted && imageFile != null) {
      if (crop != null) {
        await editImage(
          context,
          Img(file: imageFile.path),
          cropOnly: true,
          forceCropAspect: crop,
          onDone: onChosen,
        );
      } else {
        onChosen.call(Img(file: imageFile.path));
      }
    }
  }
}
