import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat/ui/image_viewer.dart';
import 'package:groupchat/ui/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../src/rust/api/rust.dart';
import 'image_editor.dart';

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

  void editImage(
    Img image, {
    bool profile = false,
    bool cropOnly = false,
    double? forceCropAspect,
    void Function(Uint8List bytes)? onDone,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: image,
          cropOnly: cropOnly,
          forceCropAspect: forceCropAspect,
          onDone: onDone,
        ),
      ),
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
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () {
              Navigator.pop(context);
              setState(() => widget.controller.logout());
            },
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
                        width: 200,
                        height: 200,
                        child: Stack(
                          children: [
                            AnyImage(
                              circle: true,
                              circleRadius: double.infinity,
                              bytes: tempImage,
                              url: delta.imageUrl,
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
                                  if (delta.imageUrl == null &&
                                      tempImage == null) {
                                    var newImage = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (newImage != null) {
                                      editImage(
                                        Img(file: newImage.path),
                                        profile: true,
                                        cropOnly: true,
                                        forceCropAspect: 1 / 1,
                                        onDone: (bytes) => setState(() {
                                          tempImage = bytes;
                                          delta.imageUrl =
                                              newImage.path +
                                              DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString();
                                        }),
                                      );
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                          forceCropAspect: 1 / 1,
                                          onReplace: (image, index) {
                                            setState(() {
                                              tempImage = image.bytes;
                                              delta.imageUrl = image.file;
                                            });
                                          },
                                          onEdit: (bytes, index) =>
                                              setState(() {
                                                tempImage = bytes;
                                                delta.imageUrl = null;
                                              }),
                                          onTrash: (image, index) =>
                                              setState(() {
                                                tempImage = null;
                                                delta.imageUrl = null;
                                              }),
                                          images: [
                                            Img(
                                              bytes: tempImage,
                                              url: delta.imageUrl,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).displayLarge,
                      decoration: InputDecoration(
                        hintText: "Name",
                        filled: false,
                        contentPadding: EdgeInsets.all(8),
                        error: delta.name.isNotEmpty ? null : empty,
                        suffixIcon: delta.name.isNotEmpty ? null : errorIcon,
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (value) => setState(() => delta.name = value),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 1),
                      child: Text(
                        "Bio",
                        style: TextTheme.of(context).titleSmall,
                      ),
                    ),
                    TextField(
                      controller: bioController,
                      decoration: InputDecoration(
                        hintText: "Tell people about yourself!",
                        counterText: "",
                      ),
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 225,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (value) => setState(() => delta.bio = value),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 1),
                      child: Text(
                        "Email",
                        style: TextTheme.of(context).titleSmall,
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "example@email.com",
                        error: delta.validEmail() ? null : empty,
                        suffixIcon: delta.validEmail() ? null : errorIcon,
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (value) => setState(() => delta.email = value),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Photo Gallery (Min 3, Max 6)",
                      style: TextTheme.of(context).titleSmall,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.only(top: 2),
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
                      height: 275,
                      child: Center(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          children: [
                            for (final (index, image)
                                in delta.photoUrls.indexed)
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
                                      AnyImage(
                                        bytes: tempPhotos[image],
                                        url: image,
                                        fit: BoxFit.fitHeight,
                                        height: double.infinity,
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ImageViewer(
                                                  forceCropAspect: 9 / 16,
                                                  initialIndex: index,
                                                  onReplace: (img, ind) =>
                                                      setState(() {
                                                        var key =
                                                            (img.file ?? "") +
                                                            DateTime.now()
                                                                .millisecondsSinceEpoch
                                                                .toString();
                                                        delta.photoUrls[ind] =
                                                            key;
                                                        tempPhotos.remove(
                                                          img.file,
                                                        );
                                                        tempPhotos.remove(
                                                          img.url,
                                                        );
                                                        tempPhotos[key] =
                                                            img.bytes ??
                                                            Uint8List(0);
                                                      }),
                                                  onEdit: (bytes, ind) =>
                                                      setState(() {
                                                        var key =
                                                            image +
                                                            DateTime.now()
                                                                .millisecondsSinceEpoch
                                                                .toString();
                                                        delta.photoUrls[ind] =
                                                            key;
                                                        tempPhotos.remove(
                                                          image,
                                                        );
                                                        tempPhotos[key] = bytes;
                                                      }),
                                                  onTrash: (img, ind) =>
                                                      setState(() {
                                                        delta.photoUrls
                                                            .removeAt(ind);
                                                        tempPhotos.remove(
                                                          img.file,
                                                        );
                                                        tempPhotos.remove(
                                                          img.url,
                                                        );
                                                      }),
                                                  images: [
                                                    for (final img
                                                        in delta.photoUrls)
                                                      Img(
                                                        bytes: tempPhotos[img],
                                                        url: img,
                                                      ),
                                                  ],
                                                ),
                                              ),
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
                                        editImage(
                                          Img(file: newImage.path),
                                          profile: false,
                                          cropOnly: true,
                                          forceCropAspect: 9 / 16,
                                          onDone: (bytes) {
                                            var key =
                                                newImage.path +
                                                DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString();
                                            tempPhotos[key] = bytes;
                                            delta.photoUrls.add(key);
                                          },
                                        );
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
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 12,
                  bottom: 6 + MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: needsSaved
                        ? () async {
                            setState(() => isSaving = true);
                            try {
                              await widget.controller.updateMe(
                                me: delta,
                                profilePhoto: tempImage,
                                galleryPhotos: tempPhotos.isNotEmpty
                                    ? tempPhotos.values.toList()
                                    : null,
                              );
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
