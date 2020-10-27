import 'package:camera/camera.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';

class TakePicturePage extends StatefulWidget {
  final CameraDescription camera;
  final String path;

  TakePicturePage({@required this.camera, this.path});

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  CameraController _cameraController;
  Future<void> _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();

    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);
    _initializeCameraControllerFuture = _cameraController.initialize()
      ..then(
        (_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Take Picture",
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.green.withOpacity(0.7),
        onPressed: () async {
          await _takePicture(context);
        },
        label: Text(
          "Capture",
          style: TextStyle(
              color: CustomColors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.camera, size: 35, color: CustomColors.white),
      ),
      body: FutureBuilder(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;
      await _cameraController.takePicture(widget.path);

      Navigator.pop(context, widget.path);
    } catch (err) {
      Analytics.sendAnalyticsEvent(
          {'type': 'image_capture_error', 'error': err.toString()}, 'storage');
    }
  }
}
