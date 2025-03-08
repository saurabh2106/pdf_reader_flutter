import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  File? pickedFile;

  @override
  void initState() {
    super.initState();
    requestStoragePermission(); // Request permissions when app starts
  }

  Future<void> pickPDF() async {
    try {
      if (await requestStoragePermission()) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            pickedFile = File(result.files.single.path!);
          });
          debugPrint("📄 Selected PDF: ${pickedFile!.path}");
        } else {
          debugPrint("❌ No file selected");
        }
      } else {
        debugPrint("🚨 Permission not granted. Cannot pick file.");
      }
    } catch (e) {
      debugPrint("⚠️ Error picking PDF: ${e.toString()}");
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      if (await Permission.storage.isPermanentlyDenied ||
          await Permission.manageExternalStorage.isPermanentlyDenied) {
        debugPrint(
            "🚨 Storage permission permanently denied. Opening settings...");
        await openAppSettings();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: pickedFile == null,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && pickedFile != null) {
            setState(() {
              pickedFile = null;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black, // Black background
          appBar: AppBar(
            centerTitle: true,
            title: const Text("PDF Reader"),
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey[900],
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.bookmark,
                  color: Colors.white,
                  semanticLabel: 'Bookmark',
                ),
                onPressed: () {
                  _pdfViewerKey.currentState?.openBookmarkView();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  semanticLabel: 'search',
                ),
                onPressed: () {
                  _pdfViewerKey.currentState?.openBookmarkView();
                },
              ),
            ],
          ),
          body: Center(
            child: pickedFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/image/pdf.png",
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: pickPDF,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Pick PDF from Storage",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : SfPdfViewer.file(
                    pickedFile!,
                    key: _pdfViewerKey,
                  ),
          ),
        ));
  }
}
