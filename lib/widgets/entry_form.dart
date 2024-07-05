import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/journal_entry.dart';
import 'dart:io';
import '../controllers/auth_controller.dart'; // Import AuthController to get the current user

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
  File? _image;
  DateTime _selectedDate = DateTime.now();
  late GeoPoint _location;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
    _contentController = TextEditingController(text: widget.entry?.content);
    _location = widget.entry?.location ?? GeoPoint(0, 0);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = '';
      if (_image != null) {
        imageUrl = await StorageService().uploadImage(_image!);
      }
      final userId = AuthController.I.currentUser?.id;
      if (userId != null) {
        final entry = JournalEntry(
          id: widget.entry?.id ?? '',
          userId: userId, // Add userId to the entry
          title: _titleController.text,
          content: _contentController.text,
          date: _selectedDate,
          imageUrl: imageUrl,
          location: _location,
        );
        if (widget.entry == null) {
          await FirestoreService().addJournalEntry(entry);
        } else {
          await FirestoreService().updateJournalEntry(entry);
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _image == null ? Text('No image selected.') : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
