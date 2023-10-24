import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'cameraState.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import '../home.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File imageFile;
  List outputs;
  bool isLoading = false;
  final picker = ImagePicker();

  void pickImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    //print(pickedFile);
    setState(() {
      if (pickedFile != null) {
        isLoading = true;
        imageFile = File(pickedFile.path);
        print(imageFile.path);
        loadCNNImage(imageFile);
      } else {
        print('No image selected.');
      }
    });
    Navigator.of(context).pop();
  }

  loadCNNModel() async {
    await Tflite.loadModel(
      model: "assets/facial_recog_cnn.tflite",
      labels: "assets/labels.txt",
    );
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 1);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getLuminance(pixel) - mean) / std;
        //buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        //buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  loadCNNImage(File imageFile) async {
    var imageBytes = (await rootBundle.load(imageFile.path)).buffer;
    img.Image oriImage = img.grayscale(img.decodeJpg(imageBytes.asUint8List()));
    //print(anImage);
    img.Image resizeImage = img.copyResize(oriImage, height: 48, width: 48);
    //var anImage2 = img.encodeJpg(resizeImage);
    //print(anImage2);

    //print(resizeImage);
    //print(imageFile.path);
    var modelOutputs = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizeImage, 48, 0, 255),
      numResults: 7,
      threshold: 0.0,
      //imageMean: 0.0,
      //imageStd: 127.7,
    );
    setState(() {
      //var predictions = modelOutputs.map((json) => Prediction.fromJson(json)).toList();
      print('the model outputs here are $modelOutputs');
      isLoading =  false;
      outputs = modelOutputs;
    });
  }

  bottomSheetCamera(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CameraState())
                          );*/
                        },
                        child:Row(
                          children: [
                            Container(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 32,
                              )
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                'Camera',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                )
                              )
                            )
                          ],
                        )
                      )
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Row(
                          children: [
                            Container(
                              child: Icon(
                                Icons.panorama_rounded,
                                size: 32,
                              )
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                'Gallery',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                )
                              )
                            )
                          ],
                        )
                      )
                    ),
                  ],
                )
              )
            ],
          )
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadCNNModel().then((value) {
      //setState(() {
      isLoading = false;
      //});
    });
  }

  @override
  void dispose() {
    super.dispose();
    imageFile = null;
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Column(children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                bottomSheetCamera(context);
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: imageFile != null ? DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover
                  ) : null
                ),
                child: imageFile == null ? Center(
                  child: Text(
                    'Add Image',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w800
                    ),
                  )
                ) : null
              ),
            ),
          ),
          Expanded(
            child: Container(
              //color: Colors.blue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: outputs != null ? 
                      Text(
                        '${outputs[0]['label']}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800]
                        )
                      ) : Text(
                        'Prediction',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800]
                        )
                      )
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            //border: BorderSide(color: color)
                          ),
                          child: Text(
                            'Upload',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),
                          ),
                        ),
                      )
                    )
                  ],
                )
              )
            )
          ),
        ],)
      )
    );
  }
}


