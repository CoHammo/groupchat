import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat/ui/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../src/rust/api/rust.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Me me;
  late Me delta;
  late ChangesId changesId;
  bool needsSaved = false;
  bool isSaving = false;
  final ImagePicker picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  Uint8List? tempImage;
  Map<String, Uint8List> tempPhotos = {};
  final errorIcon = Icon(Icons.error_outline, color: Colors.red.shade400);
  final empty = SizedBox.shrink();

  void init() {
    me = widget.controller.getMe();
    delta = widget.controller.getMe();
    nameController = TextEditingController(text: delta.name);
    bioController = TextEditingController(text: delta.bio);
    emailController = TextEditingController(text: delta.email);
    isSaving = false;
    tempImage = null;
    tempPhotos.clear();
  }

  Future<Uint8List> editImage({
    Uint8List? imageBytes,
    required String imageString,
    required bool galleryImage,
  }) async {
    Completer<Uint8List> editedImage = Completer();
    String? file;
    String? network;
    imageString.startsWith("https://")
        ? network = imageString
        : file = imageString;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.autoSource(
          file: file,
          networkUrl: network,
          byteArray: imageBytes,
          configs: ProImageEditorConfigs(
            cropRotateEditor: CropRotateEditorConfigs(
              tools: [
                CropRotateTool.flip,
                CropRotateTool.rotate,
                CropRotateTool.reset,
              ],
              initAspectRatio: galleryImage ? 9 / 16 : 1 / 1,
              aspectRatios: [
                galleryImage
                    ? AspectRatioItem(text: "9 / 16", value: 9 / 16)
                    : AspectRatioItem(text: "Square", value: 1 / 1),
              ],
            ),
          ),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              editedImage.complete(bytes);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
    return editedImage.future;
  }

  void bottomSheet({required String imageKey, required bool galleryImage}) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      constraints: BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        return SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: IconButton(
                  onPressed: () async {
                    if (galleryImage) {
                      var bytes = await editImage(
                        imageBytes: tempPhotos[imageKey],
                        imageString: imageKey,
                        galleryImage: galleryImage,
                      );
                      var key =
                          imageKey +
                          DateTime.now().millisecondsSinceEpoch.toString();
                      tempPhotos.remove(imageKey);
                      delta.photoUrls[delta.photoUrls.indexOf(imageKey)] = key;
                      tempPhotos[key] = bytes;
                    } else {
                      var bytes = await editImage(
                        imageBytes: tempImage,
                        imageString: imageKey,
                        galleryImage: galleryImage,
                      );
                      tempImage = bytes;
                      delta.imageUrl = imageKey;
                    }
                    context.mounted ? Navigator.pop(context) : null;
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(shape: CircleBorder()),
                  icon: Icon(Icons.brush_outlined, size: 36),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 65,
                height: 65,
                child: IconButton(
                  onPressed: () {
                    if (galleryImage) {
                      tempPhotos.remove(imageKey);
                      delta.photoUrls.remove(imageKey);
                    } else {
                      tempImage = null;
                      delta.imageUrl = null;
                    }
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(shape: CircleBorder()),
                  icon: Icon(Icons.delete_outline, size: 36),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 65,
                height: 65,
                child: IconButton(
                  onPressed: () async {
                    var newImage = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (newImage != null) {
                      if (galleryImage) {
                        var bytes = await editImage(
                          imageString: newImage.path,
                          galleryImage: true,
                        );
                        var key =
                            newImage.path +
                            DateTime.now().millisecondsSinceEpoch.toString();
                        tempPhotos.remove(imageKey);
                        delta.photoUrls[delta.photoUrls.indexOf(imageKey)] =
                            key;
                        tempPhotos[key] = bytes;
                      } else {
                        var bytes = await editImage(
                          imageString: newImage.path,
                          galleryImage: false,
                        );
                        tempImage = bytes;
                        delta.imageUrl = newImage.path;
                      }
                    }
                    context.mounted ? Navigator.pop(context) : null;
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(shape: CircleBorder()),
                  icon: Icon(Icons.add, size: 36),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    init();

    changesId = widget.controller.state.nextId();
    widget.controller.state.changes(id: changesId).listen((state) {
      state.whenOrNull(
        me: () => setState(() {
          init();
          print("changed me on profile page");
        }),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.state.unlisten(id: changesId);
  }

  @override
  Widget build(BuildContext context) {
    needsSaved =
        delta.isValid() &&
        (!me.equals(other: delta) ||
            tempImage != null ||
            tempPhotos.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() => init()),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(18),
                  children: [
                    Center(
                      child: SizedBox(
                        width: 225,
                        height: 225,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: double.infinity,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundImage: tempImage == null
                                  ? delta.imageUrl != null
                                        ? NetworkImage(delta.imageUrl!)
                                        : null
                                  : MemoryImage(tempImage!),
                              child: Text(
                                me.initials(),
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            Material(
                              shape: CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.black12,
                                onTap: () async {
                                  if (delta.imageUrl == null) {
                                    var newImage = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (newImage != null) {
                                      var bytes = await editImage(
                                        imageString: newImage.path,
                                        galleryImage: false,
                                      );
                                      setState(() {
                                        tempImage = bytes;
                                        delta.imageUrl = newImage.path;
                                      });
                                    }
                                  }
                                },
                                onLongPress: () {
                                  if (delta.imageUrl != null) {
                                    bottomSheet(
                                      imageKey: delta.imageUrl!,
                                      galleryImage: false,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: "Name",
                        filled: false,
                        contentPadding: EdgeInsets.all(8),
                        error: delta.name.isNotEmpty ? null : empty,
                        suffixIcon: delta.name.isNotEmpty ? null : errorIcon,
                      ),
                      onChanged: (value) => setState(() => delta.name = value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: bioController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.notes, size: 32),
                        hintText: "Tell people about yourself!",
                      ),
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 225,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onChanged: (value) => setState(() => delta.bio = value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email_outlined, size: 32),
                        hintText: "example@email.com",
                        error: delta.validEmail() ? null : empty,
                        suffixIcon: delta.validEmail() ? null : errorIcon,
                      ),
                      onChanged: (value) => setState(() => delta.email = value),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Photo Gallery (Min 3, Max 6)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: delta.validPhotos()
                            ? null
                            : BoxBorder.all(
                                color: Colors.red.shade400,
                                width: 2,
                              ),
                      ),
                      height: 300,
                      child: Center(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          children: [
                            for (final image in delta.photoUrls)
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 6),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      tempPhotos[image] == null
                                          ? image.startsWith("https://")
                                                ? Image.network(
                                                    image,
                                                    fit: BoxFit.fitHeight,
                                                    height: double.infinity,
                                                  )
                                                : Text("Photo Error")
                                          : Image.memory(
                                              tempPhotos[image]!,
                                              fit: BoxFit.fitHeight,
                                              height: double.infinity,
                                            ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onLongPress: () {
                                            bottomSheet(
                                              imageKey: image,
                                              galleryImage: true,
                                            );
                                          },
                                          splashColor: Colors.black12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (delta.photoUrls.length < 6)
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      var newImage = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (newImage != null) {
                                        var bytes = await editImage(
                                          imageString: newImage.path,
                                          galleryImage: true,
                                        );
                                        var key =
                                            newImage.path +
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();
                                        setState(() {
                                          tempPhotos.addAll({key: bytes});
                                          delta.photoUrls.add(key);
                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 18,
                ),
                child: SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: needsSaved
                        ? () async {
                            setState(() => isSaving = true);
                            try {
                              await widget.controller.updateMe(me: delta);
                            } on ChatError catch (e) {
                              Toast.error(e);
                            }
                            setState(() => isSaving = false);
                          }
                        : null,
                    child: isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text("Update Profile"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
