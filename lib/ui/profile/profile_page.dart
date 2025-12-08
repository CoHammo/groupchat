import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat/main.dart';
import 'package:groupchat/ui/toast.dart';
import 'package:image_picker/image_picker.dart';
import '../../src/rust/api/rust.dart';
import '../images/any_image.dart';
import '../images/image_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Me me;
  late Me delta;
  late List<Img> deltaImage;
  late List<Img> deltaPhotos;
  bool needsSaved = false;
  bool isSaving = false;
  late ChangesId changesId;
  final ImagePicker picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late TextEditingController countryCodeController;

  final errorIcon = Icon(Icons.error_outline, color: Colors.red.shade400);
  final emptyError = SizedBox.shrink();

  final greenBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(cornerRadius),
    borderSide: BorderSide(color: Colors.green.shade600, width: 2.5),
  );

  void init() {
    me = widget.controller.getMe();
    delta = widget.controller.getMe();
    nameController = TextEditingController(text: delta.name);
    bioController = TextEditingController(text: delta.bio);
    emailController = TextEditingController(text: delta.email);
    var number = delta.number();
    countryCodeController = TextEditingController(text: number.$1);
    numberController = TextEditingController(text: number.$2);

    deltaImage = [Img(url: delta.imageUrl)];
    deltaPhotos = [for (final image in delta.photoUrls) Img(url: image)];
    isSaving = false;
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
    var diffs = me.compareDelta(delta: delta);
    needsSaved = diffs.change && diffs.valid;

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
                    /// =========================
                    /// Profile Photo
                    /// =========================
                    Center(
                      child: Container(
                        width: 210,
                        height: 210,
                        padding: EdgeInsets.all(4),
                        decoration: diffs.imageChange
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: BoxBorder.all(
                                  color: Colors.green.shade600,
                                  width: 3,
                                ),
                              )
                            : null,
                        child: Stack(
                          children: [
                            AnyImage(
                              deltaImage.firstOrNull ?? Img(),
                              circle: true,
                              circleRadius: double.infinity,
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
                                onTap: () {
                                  if (deltaImage.firstOrNull == null) {
                                    ImageUtils.pickImage(
                                      context,
                                      crop: 1 / 1,
                                      onChosen: (newImage) => setState(() {
                                        deltaImage = [newImage];
                                        delta.imageUrl = newImage.key;
                                      }),
                                    );
                                  } else {
                                    ImageUtils.viewImages(
                                      context,
                                      deltaImage,
                                      forceCropAspect: 1 / 1,
                                      canReplace: true,
                                      canEdit: true,
                                      canTrash: true,
                                      leaveOnChange: true,
                                      onChange: (index, newImage) => setState(
                                        () => delta.imageUrl = newImage.key,
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

                    /// =========================
                    /// Name
                    /// =========================
                    SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: TextTheme.of(context).displayLarge,
                      decoration: InputDecoration(
                        enabledBorder: diffs.nameChange ? greenBorder : null,
                        hintText: "Name",
                        filled: false,
                        contentPadding: EdgeInsets.all(8),
                        error: !diffs.validName ? emptyError : null,
                        suffixIcon: !diffs.validName ? errorIcon : null,
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (value) => setState(() => delta.name = value),
                    ),

                    /// ===========================
                    /// Bio
                    /// ===========================
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
                        enabledBorder: diffs.bioChange ? greenBorder : null,
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

                    /// ================================
                    /// Photo Gallery
                    /// ================================
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 1),
                      child: Text(
                        "Photo Gallery (Min 3, Max 6)",
                        style: TextTheme.of(context).titleSmall,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        border: diffs.photosChange
                            ? BoxBorder.all(
                                color: diffs.validPhotos
                                    ? Colors.green.shade600
                                    : Colors.red.shade400,
                                width: 3,
                              )
                            : null,
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
                            for (final (index, img) in deltaPhotos.indexed)
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
                                        img,
                                        fit: BoxFit.fitHeight,
                                        height: double.infinity,
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            ImageUtils.viewImages(
                                              context,
                                              deltaPhotos,
                                              forceCropAspect: 9 / 16,
                                              index: index,
                                              canReplace: true,
                                              canEdit: true,
                                              canTrash: true,
                                              onChange: (index, img) =>
                                                  setState(
                                                    () =>
                                                        delta.photoUrls[index] =
                                                            img.file ??
                                                            img.url ??
                                                            "",
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
                            if (deltaPhotos.length < 6)
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      var imageFile = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (imageFile != null) {
                                        if (context.mounted) {
                                          ImageUtils.editImage(
                                            context,
                                            Img(file: imageFile.path),
                                            cropOnly: true,
                                            forceCropAspect: 9 / 16,
                                            onDone: (newImage) => setState(() {
                                              deltaPhotos.add(newImage);
                                              delta.photoUrls.add(newImage.key);
                                            }),
                                          );
                                        }
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

                    /// ==============================
                    /// Email
                    /// ==============================
                    SizedBox(height: 15),
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
                        enabledBorder: diffs.emailChange ? greenBorder : null,
                        hintText: "example@email.com",
                        error: !diffs.validEmail ? emptyError : null,
                        suffixIcon: !diffs.validEmail ? errorIcon : null,
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (value) => setState(() => delta.email = value),
                    ),

                    /// ==============================
                    /// Phone Number
                    /// ==============================
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 1),
                      child: Text(
                        "Phone Number",
                        style: TextTheme.of(context).titleSmall,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: countryCodeController,
                            maxLength: 3,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(
                              enabledBorder: diffs.numberChange
                                  ? greenBorder
                                  : null,
                              counterText: "",
                              hintText: "123",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.add,
                                  size: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: 25,
                              ),
                              error: !diffs.validNumber ? emptyError : null,
                            ),
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onChanged: (value) => setState(() {
                              var fullNumber =
                                  "+$value ${numberController.text}";
                              delta.phoneNumber = fullNumber;
                            }),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: numberController,
                            maxLength: 12,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(
                              enabledBorder: diffs.numberChange
                                  ? greenBorder
                                  : null,
                              counterText: "",
                              helperMaxLines: 0,
                              hintText: "0123456789",
                              error: !diffs.validNumber ? emptyError : null,
                              suffixIcon: !diffs.validNumber ? errorIcon : null,
                            ),
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onChanged: (value) => setState(() {
                              var fullNumber =
                                  "+${countryCodeController.text} $value";
                              delta.phoneNumber = fullNumber;
                            }),
                          ),
                        ),
                      ],
                    ),

                    /// ============================
                    /// Share Info
                    /// ============================
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: lightBoxColor,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        border: BoxBorder.all(
                          color: diffs.shareChange
                              ? Colors.green.shade600
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() {
                                if (delta.shareUrl == null) {
                                  delta.shareUrl = me.shareUrl ?? "";
                                  delta.shareQrCodeUrl =
                                      me.shareQrCodeUrl ?? "";
                                } else {
                                  delta.shareUrl = null;
                                  delta.shareQrCodeUrl = null;
                                }
                              }),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      "Allow Sharing",
                                      style: TextTheme.of(context).titleSmall,
                                    ),
                                    Spacer(),
                                    Switch(
                                      value: delta.shareUrl != null,
                                      onChanged: (value) => setState(() {
                                        if (value) {
                                          delta.shareUrl = me.shareUrl ?? "";
                                          delta.shareQrCodeUrl =
                                              me.shareQrCodeUrl ?? "";
                                        } else {
                                          delta.shareUrl = null;
                                          delta.shareQrCodeUrl = null;
                                        }
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (me.shareUrl != null &&
                              me.shareQrCodeUrl != null) ...[
                            SizedBox(
                              child: Divider(
                                thickness: 1,
                                height: 4,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                me.shareUrl!,
                                style: TextTheme.of(context).titleSmall,
                              ),
                            ),
                            SizedBox(
                              child: Divider(
                                thickness: 1,
                                height: 4,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              height: 350,
                              child: AnyImage(Img(url: me.shareQrCodeUrl)),
                            ),
                          ],
                        ],
                      ),
                    ),

                    /// ============================
                    /// End of Profile Info
                    /// ============================
                  ],
                ),
              ),

              /// ==========================
              /// Update Profile Button
              /// ==========================
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
                                toggleSharing: diffs.shareChange,
                                profilePhoto: deltaImage.firstOrNull?.bytes,
                                galleryPhotos: deltaPhotos.isNotEmpty
                                    ? [
                                        for (final img in deltaPhotos)
                                          (img.bytes, img.url ?? ""),
                                      ]
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
