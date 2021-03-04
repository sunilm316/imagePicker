import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;

  ImagePickerDialog(this._listener, this._controller);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    var _duration = new Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new InkWell(
                  onTap: () => _listener.openCamera(),
                  child: roundedButton("Camera", const Color(0xFF167F67),
                      const Color(0xFFFFFFFF)),
                ),
                new InkWell(
                  onTap: () => _listener.openGallery(),
                  child: roundedButton("Gallery", const Color(0xFF167F67),
                      const Color(0xFFFFFFFF)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(15.0),
          alignment: FractionalOffset.center,
          child: Text(
            buttonLabel,
            style: new TextStyle(
                color: textColor, fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
    return loginBtn;
  }
}

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image!=null)
      cropImage(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image!=null)
      cropImage(image);
  }

  void init() {
    imagePicker = new ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  void dispose() {
    _controller.dispose();
  }

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 1.4,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    _listener.userImage(croppedFile);
  }

  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  userImage(File _image);
}
