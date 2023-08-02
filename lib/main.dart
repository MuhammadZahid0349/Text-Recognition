// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:text_recognition_flutter/result_screen.dart';

// void main() {
//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Text Recognition Flutter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
//   bool _isPermissionGranted = false;

//   late final Future<void> _future;
//   CameraController? _cameraController;

//   final textRecognizer = TextRecognizer();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     _future = _requestCameraPermission();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopCamera();
//     textRecognizer.close();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }

//     if (state == AppLifecycleState.inactive) {
//       _stopCamera();
//     } else if (state == AppLifecycleState.resumed &&
//         _cameraController != null &&
//         _cameraController!.value.isInitialized) {
//       _startCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _future,
//       builder: (context, snapshot) {
//         return Stack(
//           children: [
//             if (_isPermissionGranted)
//               FutureBuilder<List<CameraDescription>>(
//                 future: availableCameras(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     _initCameraController(snapshot.data!);

//                     return Center(child: CameraPreview(_cameraController!));
//                   } else {
//                     return const LinearProgressIndicator();
//                   }
//                 },
//               ),
//             Scaffold(
//               appBar: AppBar(
//                 title: const Text('Text Recognition Sample'),
//               ),
//               backgroundColor: _isPermissionGranted ? Colors.transparent : null,
//               body: _isPermissionGranted
//                   ? Column(
//                       children: [
//                         Expanded(
//                           child: Container(),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.only(bottom: 30.0),
//                           child: Center(
//                             child: ElevatedButton(
//                               onPressed: _scanImage,
//                               child: const Text('Scan text'),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : Center(
//                       child: Container(
//                         padding: const EdgeInsets.only(left: 24.0, right: 24.0),
//                         child: const Text(
//                           'Camera permission denied',
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     _isPermissionGranted = status == PermissionStatus.granted;
//   }

//   void _startCamera() {
//     if (_cameraController != null) {
//       _cameraSelected(_cameraController!.description);
//     }
//   }

//   void _stopCamera() {
//     if (_cameraController != null) {
//       _cameraController?.dispose();
//     }
//   }

//   void _initCameraController(List<CameraDescription> cameras) {
//     if (_cameraController != null) {
//       return;
//     }

//     // Select the first rear camera.
//     CameraDescription? camera;
//     for (var i = 0; i < cameras.length; i++) {
//       final CameraDescription current = cameras[i];
//       if (current.lensDirection == CameraLensDirection.back) {
//         camera = current;
//         break;
//       }
//     }

//     if (camera != null) {
//       _cameraSelected(camera);
//     }
//   }

//   Future<void> _cameraSelected(CameraDescription camera) async {
//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.max,
//       enableAudio: false,
//     );

//     await _cameraController!.initialize();
//     await _cameraController!.setFlashMode(FlashMode.off);

//     if (!mounted) {
//       return;
//     }
//     setState(() {});
//   }

//   Future<void> _scanImage() async {
//     if (_cameraController == null) return;

//     final navigator = Navigator.of(context);

//     try {
//       final pictureFile = await _cameraController!.takePicture();

//       final file = File(pictureFile.path);

//       final inputImage = InputImage.fromFile(file);
//       final recognizedText = await textRecognizer.processImage(inputImage);

//       await navigator.push(
//         MaterialPageRoute(
//           builder: (BuildContext context) =>
//               ResultScreen(text: recognizedText.text),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('An error occurred when scanning text'),
//         ),
//       );
//     }
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition example"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
                if (imageFile != null) Image.file(File(imageFile!.path)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.grey,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.grey,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    scannedText,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}
