import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imagepickerapp/Components/ImagePickerComponent.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  ImagePickerHandler imagePicker;
  AnimationController _controller;
  File _image;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    checkPermission();
    imagePicker.init();
    super.initState();
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Picker"), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
              icon: Icon(
                CupertinoIcons.camera_fill,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              onPressed: () {
                imagePicker.showDialog(context);
              }),
        ),
      ]),
      body: ListView(
        children: [
          showSelectedImage(),
        ],
      ),
    );
  }

  checkPermission() async {
    var camStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;
    if (!camStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  showSelectedImage() {
    return _image != null
        ? Container(
            height: 250.0,
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new ExactAssetImage(_image.path),
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container();
  }
}
