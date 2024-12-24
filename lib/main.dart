import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCU_M32ciniLVsotqGaQxUX6593V1sL2DA",
        appId: "1:77417343007:android:e85ad5b9e1c35893e60d2a",
        messagingSenderId: "77417343007",
        projectId: "care-59e97",
        databaseURL: "https://care-59e97-default-rtdb.firebaseio.com",
      ),
    );
  } catch (e) {
    if (Firebase.apps.isNotEmpty) {
      Firebase.app();
    } else {
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment App',
      home: const HomePage(),
    );
  }
}

class WidgetSelectorPage extends StatefulWidget {
  final List<String> selectedWidgets;

  const WidgetSelectorPage({
    Key? key,
    required this.selectedWidgets,
  }) : super(key: key);

  @override
  _WidgetSelectorPageState createState() => _WidgetSelectorPageState();
}

class _WidgetSelectorPageState extends State<WidgetSelectorPage> {
  late List<String> _selectedWidgets;

  @override
  void initState() {
    super.initState();
    _selectedWidgets = List.from(widget.selectedWidgets);
  }

  Widget _buildSelectorOption(String title, String value) {
    bool isSelected = _selectedWidgets.contains(value);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // White background around the dot
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWidgets.remove(value);
              } else {
                _selectedWidgets.add(value);
              }
            });
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Color.fromARGB(255, 84, 236, 84)
                      : Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedWidgets.remove(value);
            } else {
              _selectedWidgets.add(value);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 240, 252, 236), // Green background for page
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSelectorOption('Text Widget', 'textbox'),
                      const SizedBox(height: 80),
                      _buildSelectorOption('Image Widget', 'imagebox'),
                      const SizedBox(height: 80),
                      _buildSelectorOption('Button Widget', 'savebutton'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                width: 220,
                height: 50,
                margin: const EdgeInsets.only(bottom: 80),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedWidgets);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 176, 252, 172),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Import Widgets',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                    ),
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
                color: Color.fromARGB(255, 176, 252, 172),
                fontSize: 14,
              ),
            ),
          ),
          backgroundColor: Colors.green.shade50,
          duration: Duration(seconds: 2),
          elevation: 0, // Removes shadow to match the image
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
                  style: TextStyle(color: Colors.black87),
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
