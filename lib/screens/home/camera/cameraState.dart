import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraState extends StatefulWidget {
  CameraState({Key key}) : super(key: key);
  @override
  _CameraStateState createState() => _CameraStateState();
}

class _CameraStateState extends State<CameraState> {
  Future<void> _controllerInitializer;
  CameraController _controller;
  List cameras;
  int selectedCameraIndex;
  XFile imageFile;
  String imgPath;
  String thePath;

  getCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });
    try {
      _controllerInitializer = _controller.initialize();
    } on CameraException catch (e) {
      print('the camera error is ${e.toString()}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  void onSwitchCamera() {
    selectedCameraIndex = selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    getCamera(selectedCamera);
  }

  Future<XFile> _onCapturePressed(context) async {
    try {
      //final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      XFile file = await _controller.takePicture();
      return file;

    } catch (e) {
      print('the error is ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        print('there is a camera');
        setState(() {
          selectedCameraIndex = 0;
        });
        getCamera(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('#### ERROR ERROR #### ${err.code}:, Error message : ${err.message}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: FutureBuilder(
                future: _controllerInitializer,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return Container(
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          'loading...', 
                          style: TextStyle(
                            color: Colors.grey[50]
                          )
                        )
                      )
                    );
                  }
                }
              )
            )
          ]
        )
      )
    );
  }
}

