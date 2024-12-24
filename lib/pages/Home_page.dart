import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widget_app/pages/Selector_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _selectedWidgets = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _showWarning = false;
  File? _image;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('widgets');

  Future<void> _navigateToWidgetSelector() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetSelectorPage(
          selectedWidgets: _selectedWidgets,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedWidgets.clear();
        _selectedWidgets.addAll(result);
        _showWarning = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      setState(() {
        _image = imageFile;
        _base64Image = base64Image;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_selectedWidgets.contains('textbox') &&
        !_selectedWidgets.contains('imagebox')) {
      setState(() => _showWarning = true);
      return;
    }

    if (_selectedWidgets.contains('textbox') && _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _database.push().set({
        'text':
            _selectedWidgets.contains('textbox') ? _textController.text : null,
        'image': _selectedWidgets.contains('imagebox') ? _base64Image : null,
        'timestamp': ServerValue.timestamp,
      });

      setState(() {
        _showWarning = false;
        _image = null;
        _base64Image = null;
        _textController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Successfully Saved',
              style: TextStyle(
                color: Color.fromARGB(255, 84, 236, 84),
                fontSize: 14,
              ),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 176, 252, 172),
          duration: Duration(seconds: 2),
          elevation: 0,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Assignment App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 240, 252, 236),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedWidgets.isEmpty)
                    const Text(
                      'No widget is added',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_selectedWidgets.contains('textbox'))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Text',
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 40,
                  ),
                  if (_selectedWidgets.contains('imagebox'))
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _image == null
                            ? const Center(
                                child: Text(
                                'Upload Image',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))
                            : null,
                      ),
                    ),
                  if (_selectedWidgets.contains('savebutton')) ...[
                    if (_showWarning)
                      Container(
                        padding: const EdgeInsets.all(80),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: const Text(
                          'Add at-least a widget to save',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Container(
                        width: 90,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 176, 252, 172),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1),
                                side:
                                    BorderSide(color: Colors.black, width: 1)),
                          ),
                          child: Text(
                            'Save',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              width: 220,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: _navigateToWidgetSelector,
                label: const Text(
                  'Add Widgets',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
                backgroundColor: Color.fromARGB(255, 176, 252, 172),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
