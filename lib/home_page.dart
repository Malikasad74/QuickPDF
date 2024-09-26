import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // Fixed constructor

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  final List<File> _image = []; // Proper initialization of the list

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path)); // Ensure that you're using File for picked image
      } else {
        print('No Image Selected');
      }
    });
  }

  Future<void> createPDF(List<File> imageFiles) async {
    for (var img in imageFiles) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
  }

  Future<void> savePDFtoExternalStorage() async {
    // Request permission to write to external storage
    if (await Permission.storage.request().isGranted) {
      await createPDF(_image);

      // Define the file path in the external storage directory (e.g., Downloads)
      String downloadsPath = '/storage/emulated/0/Download';
      final filePath = p.join(downloadsPath, 'generated_pdf.pdf');

      // Save the PDF file to external storage
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to: ${file.path}');

      Flushbar(
        title: 'Success',
        message: 'PDF saved to Downloads folder in External Storage!',
        duration: Duration(seconds: 3),
      ).show(context);
    } else {
      print('Permission denied');
      Flushbar(
        title: 'Error',
        message: 'Permission to access external storage was denied.',
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.restart_alt_rounded),
          onPressed: () {
            setState(() {
              _image.clear(); // Clear selected images
            });
          },
        ),
        centerTitle: true,
        title: Text('Image to PDF'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              if (_image.isNotEmpty) {
                savePDFtoExternalStorage();
              } else {
                Flushbar(
                  title: 'Error',
                  message: 'Please select at least one image to create PDF.',
                  duration: Duration(seconds: 3),
                ).show(context);
              }
            },
          ),
        ],
        backgroundColor: Colors.pinkAccent[400],
      ),
      body: _image.isNotEmpty
          ? ListView.builder(
        itemCount: _image.length,
        itemBuilder: (context, index) => Container(
          height: 400,
          width: double.infinity,
          margin: EdgeInsets.all(0),
          child: Image.file(
            _image[index],
            fit: BoxFit.contain,
          ),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(20),
                dashPattern: [10, 10],
                color: Colors.black,
                strokeWidth: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink[50]),
                    height: 520,
                    width: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 60,
                          color: Colors.pinkAccent[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No image is Selected',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.redAccent[400],
            onPressed: () => getImage(ImageSource.gallery),
            child: Icon(Icons.photo_library),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.redAccent[400],
            onPressed: () => getImage(ImageSource.camera),
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
