import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo/apptheme.dart';
import 'package:provider/provider.dart';

import '../providers/submit_page_provider.dart';

class CategoryImages extends StatefulWidget {
  CategoryImages({Key? key}) : super(key: key);
  // final List<File> images;

  @override
  State<CategoryImages> createState() => _CategoryImagesState();
}

class _CategoryImagesState extends State<CategoryImages> {
  static const int _numberOfImages = 4;

  Future pickImage(ImageSource imageSource, SubmitPageProvider manager) async {
    try {
      final image =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 80);
      if (image == null) return;

      final imageFile = File(image.path);
      setState(
        () => manager.images.add(imageFile),
      );
      Navigator.pop(context);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  List<Widget> builImages(List<File> images, SubmitPageProvider manager) {
    List<Widget> list = [];
    for (var item in images) {
      list.add(imageWrapper(item, manager));
    }
    return list;
  }

  Widget imageWrapper(File image, SubmitPageProvider manager) {
    return GestureDetector(
      child: SizedBox(
        height: 80,
        width: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
      onLongPress: () {
        manager.removeItemToImagesList(image);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<SubmitPageProvider>(context, listen: false);
    // final _images = manager.images;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 10.0,
          children: manager.images.length < _numberOfImages
              ? [
                  InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Ink(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppTheme.background.withOpacity(0.3),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                    ),
                    onTap: () => pickImageModal(context, manager),
                  ),
                  ...builImages(manager.images, manager),
                ]
              : builImages(manager.images, manager),
        )
      ],
    );
  }

  void pickImageModal(BuildContext context, SubmitPageProvider manager) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Row(
                  children: const [
                    Icon(
                      Icons.photo,
                      size: 40,
                    ),
                    Text(
                      'Pick from Gallery',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                onTap: () => pickImage(ImageSource.gallery, manager),
              ),
              InkWell(
                child: Row(
                  children: const [
                    Icon(
                      Icons.photo_camera,
                      size: 40,
                    ),
                    Text(
                      'Capture a Photo',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                onTap: () => pickImage(ImageSource.camera, manager),
              ),
            ],
          ),
        );
      },
    );
  }
}
