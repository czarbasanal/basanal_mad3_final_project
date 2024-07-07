import 'dart:io';
import 'dart:typed_data';
import 'package:basanal_mad3_final_project/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:exif/exif.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/user_data_controller.dart';
import '../routing/router.dart';
import '../screens/location_picker_screen.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/journal_entry.dart';
import '../dialogs/waiting_dialog.dart';

class EntryForm extends StatefulWidget {
  final JournalEntry? entry;

  EntryForm({this.entry});

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<File> _images = [];
  DateTime _selectedDate = DateTime.now();
  late GeoPoint _location;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
    _contentController = TextEditingController(text: widget.entry?.content);
    _location = widget.entry?.location ?? const GeoPoint(0, 0);
    if (widget.entry != null) {
      _imageUrls = widget.entry!.imageUrls;
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
      await _extractLocationFromImage(File(pickedFile.path));
    }
  }

  Future<void> _extractLocationFromImage(File image) async {
    final bytes = await image.readAsBytes();
    final data = await readExifFromBytes(bytes);

    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    }

    if (data.containsKey('GPSLatitude') && data.containsKey('GPSLongitude')) {
      final gpsLat = data['GPSLatitude']!;
      final gpsLong = data['GPSLongitude']!;
      final lat = _convertToDegree(gpsLat.values as List<dynamic>);
      final long = _convertToDegree(gpsLong.values as List<dynamic>);
      setState(() {
        _location = GeoPoint(lat, long);
      });
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = GeoPoint(position.latitude, position.longitude);
      });
    }
  }

  double _convertToDegree(List<dynamic> values) {
    double degrees = values[0].toDouble();
    double minutes = values[1].toDouble() / 60;
    double seconds = values[2].toDouble() / 3600;
    return degrees + minutes + seconds;
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
      _pickLocationOnMap();
    }
  }

  Future<void> _pickLocationOnMap() async {
    LatLng? selectedLocation =
        await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LocationPickerScreen(),
    ));
    if (selectedLocation != null) {
      setState(() {
        _location =
            GeoPoint(selectedLocation.latitude, selectedLocation.longitude);
      });
    }
  }

  Future<Uint8List?> compressAndTryCatch(String path) async {
    Uint8List? result;
    try {
      result = await FlutterImageCompress.compressWithFile(
        path,
        format: CompressFormat.heic,
      );
    } on UnsupportedError catch (e) {
      print(e);
      result = await FlutterImageCompress.compressWithFile(
        path,
        format: CompressFormat.jpeg,
      );
    }
    return result;
  }

  Future<File> _compressImage(File file) async {
    Uint8List? compressedBytes = await compressAndTryCatch(file.path);
    final tempDir = await getTemporaryDirectory();
    final compressedImage =
        File('${tempDir.path}/${file.uri.pathSegments.last}_compressed.jpg');
    return compressedImage.writeAsBytes(compressedBytes!);
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final userId = GetIt.instance<UserDataController>().currentUserId;
      if (userId != null) {
        await WaitingDialog.show(
          context,
          future: _processSave(userId),
          prompt: "Saving entry...",
        );
        GlobalRouter.instance.router.go(HomeScreen.route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }

  Future<void> _processSave(String userId) async {
    List<String> imageUrls = _imageUrls;
    for (File image in _images) {
      File compressedImage = await _compressImage(image);
      String imageUrl = await StorageService().uploadImage(compressedImage);
      imageUrls.add(imageUrl);
    }

    final entry = JournalEntry(
      id: widget.entry?.id ?? '',
      userId: userId,
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      imageUrls: imageUrls,
      location: _location,
    );
    if (widget.entry == null) {
      await FirestoreService().addJournalEntry(entry);
    } else {
      await FirestoreService().updateJournalEntry(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(_imageUrls[index]),
                    );
                  },
                ),
              ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(_images[index]),
                    );
                  },
                ),
              ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  child: const Text('Capture Image'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: const Text('Upload Image'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
