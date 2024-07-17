import 'dart:io';
import 'dart:typed_data';
import 'package:basanal_mad3_final_project/screens/home_screen.dart';
import 'package:basanal_mad3_final_project/screens/journal_entries_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';

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
  final List<File> _images = [];
  DateTime _selectedDate = DateTime.now();
  late GeoPoint _location;
  List<String> _imageUrls = [];
  String? _address;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
    _contentController = TextEditingController(text: widget.entry?.content);
    _location = widget.entry?.location ?? const GeoPoint(0, 0);
    if (widget.entry != null) {
      _imageUrls = widget.entry!.imageUrls;
      _selectedDate = widget.entry!.date;
      _getAddressFromGeoPoint(widget.entry!.location);
    }
  }

  Future<void> _getAddressFromGeoPoint(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
      });
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        _address = "Unknown location";
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = GeoPoint(position.latitude, position.longitude);
      _getAddressFromGeoPoint(_location);
    });
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
        _getAddressFromGeoPoint(_location);
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
      final userId = UserDataController.instance.currentUserId;
      if (userId != null) {
        await WaitingDialog.show(
          context,
          future: _processSave(userId),
          prompt: "Saving entry...",
        );

        GlobalRouter.I.router.go(JournalEntriesScreen.route);
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

  Future<void> _deleteEntry() async {
    if (widget.entry != null) {
      await WaitingDialog.show(
        context,
        future: FirestoreService().deleteJournalEntry(widget.entry!.id),
        prompt: "Deleting entry...",
      );
      GlobalRouter.I.router.go(JournalEntriesScreen.route);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal Entry Deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextFormField(
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                cursorColor: Colors.black87,
                cursorErrorColor: Colors.redAccent,
                controller: _titleController,
                decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600),
                    border: InputBorder.none),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            if (widget.entry != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.calendar,
                            color: Colors.deepPurpleAccent),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMMd().format(_selectedDate),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid,
                            color: Colors.deepPurpleAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address ?? 'Fetching location...',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextFormField(
                controller: _contentController,
                cursorColor: Colors.black87,
                cursorErrorColor: Colors.redAccent,
                decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none),
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 400,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageUrls.removeAt(index);
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.clear,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 360,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _images[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.clear,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: _pickImageFromCamera,
                  splashColor: Colors.grey.shade100,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.photo_camera),
                      SizedBox(width: 10),
                      Text('Take a photo')
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                MaterialButton(
                  onPressed: _pickImageFromGallery,
                  splashColor: Colors.grey.shade100,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.up_arrow),
                      SizedBox(width: 10),
                      Text('Upload')
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    )),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    _saveEntry();
                  },
                  color: Colors.deepPurpleAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            if (widget.entry != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: const Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      )),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _deleteEntry,
                    color: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
