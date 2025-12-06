import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'image_utils.dart';

class ImageEditor extends StatelessWidget {
  const ImageEditor(
    this.image, {
    super.key,
    this.cropOnly = false,
    this.forceCropAspect,
    this.onDone,
  });

  final Img image;
  final bool cropOnly;
  final double? forceCropAspect;
  final void Function(Img newImage)? onDone;

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
              onDone?.call(image.edit(bytes));
              Navigator.pop(context);
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
            onDone?.call(image.edit(bytes));
            Navigator.pop(context);
          },
        ),
      );
    }
  }
}
