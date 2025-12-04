import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'image_viewer.dart';

class ImageEditor extends StatelessWidget {
  const ImageEditor({
    super.key,
    required this.image,
    // this.config,
    this.cropOnly = false,
    this.forceCropAspect,
    this.onDone,
  });

  final Img image;
  // final ProImageEditorConfigs? config;
  final bool cropOnly;
  final double? forceCropAspect;
  // final CropRotateEditorConfigs? cropConfig;
  final void Function(Uint8List bytes)? onDone;

  @override
  Widget build(BuildContext context) {
    if (cropOnly) {
      return CropRotateEditor.autoSource(
        byteArray: image.bytes,
        file: image.file,
        networkUrl: image.url,
        initConfigs: CropRotateEditorInitConfigs(
          convertToUint8List: true,
          theme: Theme.of(context),
          configs: ProImageEditorConfigs(
            cropRotateEditor: CropRotateEditorConfigs(
              tools: [
                CropRotateTool.flip,
                CropRotateTool.rotate,
                CropRotateTool.reset,
              ],
              initAspectRatio: forceCropAspect,
            ),
          ),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              onDone?.call(bytes);
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } else {
      return ProImageEditor.autoSource(
        byteArray: image.bytes,
        file: image.file,
        networkUrl: image.url,
        configs: ProImageEditorConfigs(
          cropRotateEditor: CropRotateEditorConfigs(
            initAspectRatio: forceCropAspect,
            tools: [
              CropRotateTool.flip,
              if (forceCropAspect == null) CropRotateTool.aspectRatio,
              CropRotateTool.rotate,
              CropRotateTool.reset,
            ],
          ),
        ),
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (bytes) async {
            onDone?.call(bytes);
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }
}
